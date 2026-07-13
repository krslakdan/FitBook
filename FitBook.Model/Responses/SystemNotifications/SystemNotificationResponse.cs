using FitBook.Model.Enums;

namespace FitBook.Model.Responses.SystemNotifications;

public class SystemNotificationResponse : IEntityResponse
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime? ReadAtUtc { get; set; }
    public NotificationType NotificationType { get; set; }
    public int UserAccountId { get; set; }
    public DateTime CreatedAtUtc { get; set; }
    public DateTime? UpdatedAtUtc { get; set; }
}
