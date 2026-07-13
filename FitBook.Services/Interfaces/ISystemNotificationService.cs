using FitBook.Model.Responses.SystemNotifications;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface ISystemNotificationService : IBaseReadService<SystemNotificationResponse, SystemNotificationSearchObject>
{
    Task MarkAsReadAsync(int id, CancellationToken cancellationToken = default);
}
