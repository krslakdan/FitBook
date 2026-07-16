using FitBook.Model.Messages;

namespace FitBook.Services.Messaging;

public interface IEmailNotificationPublisher
{
    Task PublishAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default);
}
