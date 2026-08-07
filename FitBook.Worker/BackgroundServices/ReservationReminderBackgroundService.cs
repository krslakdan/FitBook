using FitBook.Services.Interfaces;
using FitBook.Worker.Services;

namespace FitBook.Worker.BackgroundServices;

public class ReservationReminderBackgroundService : PollingBackgroundService
{
    private static readonly TimeSpan ReminderLeadTime = TimeSpan.FromHours(24);

    public ReservationReminderBackgroundService(IServiceScopeFactory scopeFactory, DatabaseReadyGate databaseReadyGate, ILogger<ReservationReminderBackgroundService> logger)
        : base(scopeFactory, databaseReadyGate, logger)
    {
    }

    protected override TimeSpan PollInterval => TimeSpan.FromMinutes(15);

    protected override TimeSpan FailureRetryInterval => TimeSpan.FromSeconds(30);

    protected override string FailureMessage => "Failed to process due reservation reminders.";

    protected override async Task RunIterationAsync(IServiceProvider scopedServices, CancellationToken stoppingToken)
    {
        var reminderService = scopedServices.GetRequiredService<IReminderService>();
        await reminderService.SendDueReservationRemindersAsync(ReminderLeadTime, stoppingToken);
        await reminderService.SendDueTrainerTermRemindersAsync(ReminderLeadTime, stoppingToken);
    }
}
