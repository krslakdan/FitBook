using FitBook.Model.Enums;

namespace FitBook.Model.Responses.Dashboard;

public class DashboardSummaryResponse
{
    public int TotalUsers { get; set; }
    public double? TotalUsersChangePercent { get; set; }

    public int ActiveMemberships { get; set; }
    public double? ActiveMembershipsChangePercent { get; set; }

    public int TodayReservations { get; set; }
    public double? TodayReservationsChangePercent { get; set; }

    public decimal MonthRevenue { get; set; }
    public string RevenueCurrency { get; set; } = string.Empty;
    public double? MonthRevenueChangePercent { get; set; }

    public List<DashboardDailyCount> ReservationsPerDay { get; set; } = [];
    public List<DashboardTopTraining> TopTrainings { get; set; } = [];
    public List<DashboardRecentReservation> RecentReservations { get; set; } = [];
    public List<DashboardRecentPayment> RecentPayments { get; set; } = [];
    public List<DashboardActivity> RecentActivities { get; set; } = [];
}

public class DashboardDailyCount
{
    public DateTime DateUtc { get; set; }
    public int Count { get; set; }
}

public class DashboardTopTraining
{
    public string TrainingName { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public int ReservationCount { get; set; }
    public double SharePercent { get; set; }
}

public class DashboardRecentReservation
{
    public string UserFullName { get; set; } = string.Empty;
    public string? UserImageUrl { get; set; }
    public string TrainingName { get; set; } = string.Empty;
    public DateTime TermStartUtc { get; set; }
    public DateTime TermEndUtc { get; set; }
    public ReservationStatus Status { get; set; }
    public DateTime ReservedAtUtc { get; set; }
}

public class DashboardActivity
{
    public NotificationType Type { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; }
}

public class DashboardRecentPayment
{
    public string UserFullName { get; set; } = string.Empty;
    public string PackageName { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Currency { get; set; } = string.Empty;
    public PaymentStatus Status { get; set; }
    public DateTime? PaidAtUtc { get; set; }
    public DateTime CreatedAtUtc { get; set; }
}
