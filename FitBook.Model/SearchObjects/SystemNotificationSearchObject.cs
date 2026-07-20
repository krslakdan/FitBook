using FitBook.Model.Enums;

namespace FitBook.Model.SearchObjects;

public class SystemNotificationSearchObject : BaseSearchObject
{
    public bool? IsRead { get; set; }
    public NotificationType? NotificationType { get; set; }
    public int? UserAccountId { get; set; }
    public DateTime? CreatedFromUtc { get; set; }
    public DateTime? CreatedToUtc { get; set; }
}
