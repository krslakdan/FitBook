namespace FitBook.Services.Database.Entities;

public class UserAccount : SoftDeletableEntity
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string? ProfileImageUrl { get; set; }
    public bool IsActive { get; set; }

    public Trainer? Trainer { get; set; }

    public ICollection<Reservation> Reservations { get; set; } = [];
    public ICollection<Reservation> ReservationStatusChanged { get; set; } = [];
    public ICollection<ReservationStatusAudit> ReservationStatusAudits { get; set; } = [];
    public ICollection<SystemNotification> Notifications { get; set; } = [];
    public ICollection<UserMembership> Memberships { get; set; } = [];
    public ICollection<MembershipPayment> Payments { get; set; } = [];
    public ICollection<RecommendationSignal> RecommendationSignals { get; set; } = [];
    public ICollection<RefreshToken> RefreshTokens { get; set; } = [];
}
