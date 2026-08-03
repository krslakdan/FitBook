using FitBook.Common.Services.Time;
using FitBook.Model.Constants;
using FitBook.Model.Enums;
using FitBook.Model.Responses.Dashboard;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services.Dashboard;

public class DashboardService : IDashboardService
{
    private const int MinReservationsDays = 7;
    private const int MaxReservationsDays = 30;
    private const int TopTrainingsCount = 4;
    private const int RecentItemsCount = 4;

    private readonly FitBookDbContext _dbContext;
    private readonly ILogger<DashboardService> _logger;

    public DashboardService(FitBookDbContext dbContext, ILogger<DashboardService> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task<DashboardSummaryResponse> GetSummaryAsync(int reservationsDays, CancellationToken cancellationToken = default)
    {
        var days = Math.Clamp(reservationsDays, MinReservationsDays, MaxReservationsDays);

        var nowUtc = DateTime.UtcNow;
        var localToday = LocalTimeProvider.LocalDate(nowUtc);
        var localMonthStart = new DateTime(localToday.Year, localToday.Month, 1);
        var todayUtc = LocalTimeProvider.ToUtc(localToday);
        var yesterdayUtc = LocalTimeProvider.ToUtc(localToday.AddDays(-1));
        var monthStartUtc = LocalTimeProvider.ToUtc(localMonthStart);
        var previousMonthStartUtc = LocalTimeProvider.ToUtc(localMonthStart.AddMonths(-1));
        var thirtyDaysAgoUtc = nowUtc.AddDays(-30);

        var totalUsers = await _dbContext.UserAccounts
            .CountAsync(u => !u.IsDeleted && u.Role == Roles.User, cancellationToken);
        var usersBeforeThisMonth = await _dbContext.UserAccounts
            .CountAsync(
                u => !u.IsDeleted && u.Role == Roles.User && u.CreatedAtUtc < monthStartUtc,
                cancellationToken);

        var activeMemberships = await _dbContext.UserMemberships
            .CountAsync(
                m => !m.IsDeleted
                    && m.Status == MembershipStatus.Active
                    && m.EndDateUtc >= nowUtc,
                cancellationToken);
        var membershipsActiveThirtyDaysAgo = await _dbContext.UserMemberships
            .CountAsync(
                m => !m.IsDeleted
                    && m.Status != MembershipStatus.Pending
                    && m.StartDateUtc <= thirtyDaysAgoUtc
                    && m.EndDateUtc >= thirtyDaysAgoUtc,
                cancellationToken);

        var todayReservations = await _dbContext.Reservations
            .CountAsync(r => r.ReservedAtUtc >= todayUtc, cancellationToken);
        var yesterdayReservations = await _dbContext.Reservations
            .CountAsync(r => r.ReservedAtUtc >= yesterdayUtc && r.ReservedAtUtc < todayUtc, cancellationToken);

        var monthRevenue = await _dbContext.MembershipPayments
            .Where(p => (p.Status == PaymentStatus.Completed || p.Status == PaymentStatus.Refunded)
                && p.PaidAtUtc >= monthStartUtc)
            .SumAsync(p => (decimal?)(p.Amount - (p.RefundAmount ?? 0m)), cancellationToken) ?? 0m;
        var previousMonthRevenue = await _dbContext.MembershipPayments
            .Where(p => (p.Status == PaymentStatus.Completed || p.Status == PaymentStatus.Refunded)
                && p.PaidAtUtc >= previousMonthStartUtc
                && p.PaidAtUtc < monthStartUtc)
            .SumAsync(p => (decimal?)(p.Amount - (p.RefundAmount ?? 0m)), cancellationToken) ?? 0m;

        var revenueCurrency = PaymentConstants.Currency;

        var seriesFromLocal = localToday.AddDays(-(days - 1));
        var seriesFromUtc = LocalTimeProvider.ToUtc(seriesFromLocal);
        var reservedAtValues = await _dbContext.Reservations
            .Where(r => r.ReservedAtUtc >= seriesFromUtc)
            .Select(r => r.ReservedAtUtc)
            .ToListAsync(cancellationToken);
        var reservationsGrouped = reservedAtValues
            .GroupBy(LocalTimeProvider.LocalDate)
            .ToDictionary(group => group.Key, group => group.Count());
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

        var totalReservations = await _dbContext.Reservations.CountAsync(cancellationToken);
        var topTrainings = await _dbContext.Trainings
            .Select(t => new
            {
                t.Name,
                CategoryName = t.TrainingCategory!.Name,
                ReservationCount = t.TrainingTerms.SelectMany(tt => tt.Reservations).Count(),
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
            RevenueCurrency = revenueCurrency,
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
