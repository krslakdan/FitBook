namespace FitBook.Services.Interfaces;

public interface IReminderService
{
    Task<int> SendDueReservationRemindersAsync(TimeSpan reminderLeadTime, CancellationToken cancellationToken = default);
    Task<int> SendDueTrainerTermRemindersAsync(TimeSpan reminderLeadTime, CancellationToken cancellationToken = default);
    Task<int> SendDueMembershipExpiryRemindersAsync(TimeSpan reminderLeadTime, CancellationToken cancellationToken = default);
}
