using FitBook.Services.Interfaces;
using FitBook.Worker.Services;

namespace FitBook.Worker.BackgroundServices;

public class MembershipExpiryReminderBackgroundService : PollingBackgroundService
{
    private static readonly TimeSpan ReminderLeadTime = TimeSpan.FromDays(3);

    public MembershipExpiryReminderBackgroundService(IServiceScopeFactory scopeFactory, DatabaseReadyGate databaseReadyGate, ILogger<MembershipExpiryReminderBackgroundService> logger)
        : base(scopeFactory, databaseReadyGate, logger)
    {
    }

    protected override TimeSpan PollInterval => TimeSpan.FromHours(6);

    protected override TimeSpan FailureRetryInterval => TimeSpan.FromSeconds(30);

    protected override string FailureMessage => "Failed to process due membership expiry reminders.";

    protected override async Task RunIterationAsync(IServiceProvider scopedServices, CancellationToken stoppingToken)
    {
        var reminderService = scopedServices.GetRequiredService<IReminderService>();
        await reminderService.SendDueMembershipExpiryRemindersAsync(ReminderLeadTime, stoppingToken);
    }
}
