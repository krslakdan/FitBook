using FitBook.Services.Interfaces;

namespace FitBook.Worker.BackgroundServices;

public class MembershipExpiryReminderBackgroundService : BackgroundService
{
    private static readonly TimeSpan PollInterval = TimeSpan.FromHours(6);
    private static readonly TimeSpan FailureRetryInterval = TimeSpan.FromSeconds(30);
    private static readonly TimeSpan ReminderLeadTime = TimeSpan.FromDays(3);

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<MembershipExpiryReminderBackgroundService> _logger;

    public MembershipExpiryReminderBackgroundService(
        IServiceScopeFactory scopeFactory,
        ILogger<MembershipExpiryReminderBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var nextDelay = PollInterval;

            try
            {
                using var scope = _scopeFactory.CreateScope();
                var reminderService = scope.ServiceProvider.GetRequiredService<IReminderService>();
                await reminderService.SendDueMembershipExpiryRemindersAsync(ReminderLeadTime, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process due membership expiry reminders. Retrying in {Delay}.", FailureRetryInterval);
                nextDelay = FailureRetryInterval;
            }

            try
            {
                await Task.Delay(nextDelay, stoppingToken);
            }
            catch (OperationCanceledException)
            {
            }
        }
    }
}
