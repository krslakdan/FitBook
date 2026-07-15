using FitBook.Model.Messages;

namespace FitBook.Worker.Services;

public interface ISmtpEmailSender
{
    Task SendAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default);
}
