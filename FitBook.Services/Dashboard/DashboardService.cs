using FitBook.Common.Services.Time;
using FitBook.Model.Constants;
using FitBook.Model.Enums;
using FitBook.Model.Responses.Dashboard;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;

namespace FitBook.Services.Dashboard;

public class DashboardService : IDashboardService
{
    private const int MinReservationsDays = 7;
    private const int MaxReservationsDays = 30;
    private const int TopTrainingsCount = 4;
    private const int RecentItemsCount = 4;
    private const string CacheKeyPrefix = "dashboard:summary:";

    private static readonly TimeSpan CacheLifetime = TimeSpan.FromSeconds(30);

    private readonly FitBookDbContext _dbContext;
    private readonly IMemoryCache _cache;
    private readonly ILogger<DashboardService> _logger;

    public DashboardService(FitBookDbContext dbContext, IMemoryCache cache, ILogger<DashboardService> logger)
    {
        _dbContext = dbContext;
        _cache = cache;
        _logger = logger;
    }

    public async Task<DashboardSummaryResponse> GetSummaryAsync(int reservationsDays, CancellationToken cancellationToken = default)
    {
        var days = Math.Clamp(reservationsDays, MinReservationsDays, MaxReservationsDays);
        var cacheKey = CacheKeyPrefix + days;

        if (_cache.TryGetValue<DashboardSummaryResponse>(cacheKey, out var cached) && cached is not null)
        {
            return cached;
        }

        var summary = await BuildSummaryAsync(days, cancellationToken);
        _cache.Set(cacheKey, summary, CacheLifetime);

        return summary;
    }

    private async Task<DashboardSummaryResponse> BuildSummaryAsync(int days, CancellationToken cancellationToken)
    {
        var nowUtc = DateTime.UtcNow;
        var localToday = LocalTimeProvider.LocalDate(nowUtc);
        var localMonthStart = new DateTime(localToday.Year, localToday.Month, 1);
        var todayUtc = LocalTimeProvider.ToUtc(localToday);
        var yesterdayUtc = LocalTimeProvider.ToUtc(localToday.AddDays(-1));
        var monthStartUtc = LocalTimeProvider.ToUtc(localMonthStart);
        var previousMonthStartUtc = LocalTimeProvider.ToUtc(localMonthStart.AddMonths(-1));
        var thirtyDaysAgoUtc = nowUtc.AddDays(-30);
        var seriesFromLocal = localToday.AddDays(-(days - 1));
        var seriesFromUtc = LocalTimeProvider.ToUtc(seriesFromLocal);
        var offsetHours = LocalTimeProvider.OffsetHours(nowUtc);

        var userStats = await _dbContext.UserAccounts
            .Where(u => !u.IsDeleted && u.Role == Roles.User)
            .GroupBy(u => 1)
            .Select(g => new
            {
                Total = g.Count(),
                BeforeThisMonth = g.Count(u => u.CreatedAtUtc < monthStartUtc),
            })
            .FirstOrDefaultAsync(cancellationToken);

        var membershipStats = await _dbContext.UserMemberships
            .Where(m => !m.IsDeleted)
            .GroupBy(m => 1)
            .Select(g => new
            {
                ActiveNow = g.Count(m => m.Status == MembershipStatus.Active && m.EndDateUtc >= nowUtc),
                ActiveThirtyDaysAgo = g.Count(m => m.Status != MembershipStatus.Pending
                    && m.StartDateUtc <= thirtyDaysAgoUtc
                    && m.EndDateUtc >= thirtyDaysAgoUtc),
            })
            .FirstOrDefaultAsync(cancellationToken);

        var reservationStats = await _dbContext.Reservations
            .GroupBy(r => 1)
            .Select(g => new
            {
                Total = g.Count(),
                Today = g.Count(r => r.ReservedAtUtc >= todayUtc),
                Yesterday = g.Count(r => r.ReservedAtUtc >= yesterdayUtc && r.ReservedAtUtc < todayUtc),
            })
            .FirstOrDefaultAsync(cancellationToken);

        var revenueStats = await _dbContext.MembershipPayments
            .Where(p => (p.Status == PaymentStatus.Completed || p.Status == PaymentStatus.Refunded)
                && p.PaidAtUtc >= previousMonthStartUtc)
            .GroupBy(p => 1)
            .Select(g => new
            {
                CurrentMonth = g.Sum(p => p.PaidAtUtc >= monthStartUtc ? p.Amount - (p.RefundAmount ?? 0m) : 0m),
                PreviousMonth = g.Sum(p => p.PaidAtUtc < monthStartUtc ? p.Amount - (p.RefundAmount ?? 0m) : 0m),
            })
            .FirstOrDefaultAsync(cancellationToken);

        var reservationsGrouped = await _dbContext.Reservations
            .Where(r => r.ReservedAtUtc >= seriesFromUtc)
            .GroupBy(r => r.ReservedAtUtc.AddHours(offsetHours).Date)
            .Select(g => new { Day = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Day, x => x.Count, cancellationToken);

        var reservationsPerDay = Enumerable.Range(0, days)
            .Select(offset =>
            {
                var localDay = seriesFromLocal.AddDays(offset);
                return new DashboardDailyCount
                {
                    DateUtc = LocalTimeProvider.ToUtc(localDay),
                    Count = reservationsGrouped.GetValueOrDefault(localDay, 0),
                };
            })
            .ToList();

        var topTrainings = await _dbContext.Trainings
            .Select(t => new
            {
                t.Name,
                CategoryName = t.TrainingCategory!.Name,
                ReservationCount = t.TrainingTerms
                    .SelectMany(tt => tt.Reservations)
                    .Count(r => r.Status != ReservationStatus.Cancelled),
            })
            .OrderByDescending(t => t.ReservationCount)
            .Take(TopTrainingsCount)
            .ToListAsync(cancellationToken);

        var recentReservations = await _dbContext.Reservations
            .OrderByDescending(r => r.ReservedAtUtc)
            .Take(RecentItemsCount)
            .Select(r => new DashboardRecentReservation
            {
                UserFullName = r.UserAccount!.FirstName + " " + r.UserAccount.LastName,
                UserImageUrl = r.UserAccount.ProfileImageUrl,
                TrainingName = r.TrainingTerm!.Training!.Name,
                TermStartUtc = r.TrainingTerm.StartTimeUtc,
                TermEndUtc = r.TrainingTerm.EndTimeUtc,
                Status = r.Status,
                ReservedAtUtc = r.ReservedAtUtc,
            })
            .ToListAsync(cancellationToken);

        var recentPayments = await _dbContext.MembershipPayments
            .Where(p => p.Status == PaymentStatus.Completed || p.Status == PaymentStatus.Refunded)
            .OrderByDescending(p => p.PaidAtUtc ?? p.CreatedAtUtc)
            .Take(RecentItemsCount)
            .Select(p => new DashboardRecentPayment
            {
                UserFullName = p.UserAccount!.FirstName + " " + p.UserAccount.LastName,
                PackageName = p.UserMembership!.MembershipPackage!.Name,
                Amount = p.Amount,
                Currency = p.Currency,
                Status = p.Status,
                PaidAtUtc = p.PaidAtUtc,
                CreatedAtUtc = p.CreatedAtUtc,
            })
            .ToListAsync(cancellationToken);

        var recentActivities = await _dbContext.SystemNotifications
            .Where(n => n.NotificationType != NotificationType.NewsPublished
                && n.NotificationType != NotificationType.ReservationReminder)
            .OrderByDescending(n => n.CreatedAtUtc)
            .Take(RecentItemsCount)
            .Select(n => new DashboardActivity
            {
                Type = n.NotificationType,
                UserFullName = n.UserAccount!.FirstName + " " + n.UserAccount.LastName,
                CreatedAtUtc = n.CreatedAtUtc,
            })
            .ToListAsync(cancellationToken);

        var totalUsers = userStats?.Total ?? 0;
        var usersBeforeThisMonth = userStats?.BeforeThisMonth ?? 0;
        var activeMemberships = membershipStats?.ActiveNow ?? 0;
        var membershipsActiveThirtyDaysAgo = membershipStats?.ActiveThirtyDaysAgo ?? 0;
        var totalReservations = reservationStats?.Total ?? 0;
        var todayReservations = reservationStats?.Today ?? 0;
        var yesterdayReservations = reservationStats?.Yesterday ?? 0;
        var monthRevenue = revenueStats?.CurrentMonth ?? 0m;
        var previousMonthRevenue = revenueStats?.PreviousMonth ?? 0m;

        _logger.LogInformation(
            "Dashboard summary generated. Users: {TotalUsers}, active memberships: {ActiveMemberships}, today reservations: {TodayReservations}.",
            totalUsers,
            activeMemberships,
            todayReservations);

        return new DashboardSummaryResponse
        {
            TotalUsers = totalUsers,
            TotalUsersChangePercent = ChangePercent(totalUsers, usersBeforeThisMonth),
            ActiveMemberships = activeMemberships,
            ActiveMembershipsChangePercent = ChangePercent(activeMemberships, membershipsActiveThirtyDaysAgo),
            TodayReservations = todayReservations,
            TodayReservationsChangePercent = ChangePercent(todayReservations, yesterdayReservations),
            MonthRevenue = monthRevenue,
            RevenueCurrency = PaymentConstants.Currency,
            MonthRevenueChangePercent = ChangePercent((double)monthRevenue, (double)previousMonthRevenue),
            ReservationsPerDay = reservationsPerDay,
            TopTrainings = topTrainings
                .Where(t => t.ReservationCount > 0)
                .Select(t => new DashboardTopTraining
                {
                    TrainingName = t.Name,
                    CategoryName = t.CategoryName,
                    ReservationCount = t.ReservationCount,
                    SharePercent = totalReservations == 0
                        ? 0
                        : Math.Round(t.ReservationCount * 100.0 / totalReservations, 1),
                })
                .ToList(),
            RecentReservations = recentReservations,
            RecentPayments = recentPayments,
            RecentActivities = recentActivities,
        };
    }

    private static double? ChangePercent(double current, double previous)
    {
        if (previous == 0)
        {
            return null;
        }

        return Math.Round((current - previous) / previous * 100.0, 1);
    }
}
