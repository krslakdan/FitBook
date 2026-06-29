using FitBook.Model.Enums;

namespace FitBook.Services.Database.Entities;

public class SystemNotification
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? ReadAtUtc { get; set; }
    public NotificationType NotificationType { get; set; }

    public int UserAccountId { get; set; }
    public UserAccount? UserAccount { get; set; }
}
