namespace FitBook.Services.Database.Entities;

public class PasswordResetToken : BaseEntity
{
    public int UserAccountId { get; set; }
    public string CodeHash { get; set; } = string.Empty;
    public DateTime ExpiresAtUtc { get; set; }
    public DateTime? UsedAtUtc { get; set; }

    public UserAccount? UserAccount { get; set; }
}
