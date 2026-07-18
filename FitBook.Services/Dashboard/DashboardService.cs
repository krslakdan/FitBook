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
        var todayUtc = nowUtc.Date;
        var yesterdayUtc = todayUtc.AddDays(-1);
        var monthStartUtc = new DateTime(todayUtc.Year, todayUtc.Month, 1, 0, 0, 0, DateTimeKind.Utc);
        var previousMonthStartUtc = monthStartUtc.AddMonths(-1);
        var thirtyDaysAgoUtc = nowUtc.AddDays(-30);

        var totalUsers = await _dbContext.UserAccounts
            .CountAsync(u => !u.IsDeleted, cancellationToken);
        var usersBeforeThisMonth = await _dbContext.UserAccounts
            .CountAsync(u => !u.IsDeleted && u.CreatedAtUtc < monthStartUtc, cancellationToken);

        var activeMemberships = await _dbContext.UserMemberships
            .CountAsync(m => !m.IsDeleted && m.Status == MembershipStatus.Active, cancellationToken);
        var membershipsActiveThirtyDaysAgo = await _dbContext.UserMemberships
            .CountAsync(
                m => !m.IsDeleted
                    && m.StartDateUtc <= thirtyDaysAgoUtc
                    && m.EndDateUtc >= thirtyDaysAgoUtc,
                cancellationToken);

        var todayReservations = await _dbContext.Reservations
            .CountAsync(r => r.ReservedAtUtc >= todayUtc, cancellationToken);
        var yesterdayReservations = await _dbContext.Reservations
            .CountAsync(r => r.ReservedAtUtc >= yesterdayUtc && r.ReservedAtUtc < todayUtc, cancellationToken);

        var monthRevenue = await _dbContext.MembershipPayments
            .Where(p => p.Status == PaymentStatus.Completed && p.PaidAtUtc >= monthStartUtc)
            .SumAsync(p => (decimal?)p.Amount, cancellationToken) ?? 0m;
        var previousMonthRevenue = await _dbContext.MembershipPayments
            .Where(p => p.Status == PaymentStatus.Completed
                && p.PaidAtUtc >= previousMonthStartUtc
                && p.PaidAtUtc < monthStartUtc)
            .SumAsync(p => (decimal?)p.Amount, cancellationToken) ?? 0m;

        var revenueCurrency = await _dbContext.MembershipPayments
            .Where(p => p.Status == PaymentStatus.Completed)
            .Select(p => p.Currency)
            .FirstOrDefaultAsync(cancellationToken) ?? string.Empty;

        var seriesFromUtc = todayUtc.AddDays(-(days - 1));
        var reservationsGrouped = await _dbContext.Reservations
            .Where(r => r.ReservedAtUtc >= seriesFromUtc)
            .GroupBy(r => r.ReservedAtUtc.Date)
            .Select(g => new { Date = g.Key, Count = g.Count() })
            .ToListAsync(cancellationToken);
        var reservationsPerDay = Enumerable.Range(0, days)
            .Select(offset =>
            {
                var date = seriesFromUtc.AddDays(offset);
                return new DashboardDailyCount
                {
                    DateUtc = date,
                    Count = reservationsGrouped.FirstOrDefault(g => g.Date == date)?.Count ?? 0,
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
