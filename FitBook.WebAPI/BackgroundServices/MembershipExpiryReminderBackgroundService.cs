using FitBook.Services.Interfaces;

namespace FitBook.WebAPI.BackgroundServices;

public class MembershipExpiryReminderBackgroundService : BackgroundService
{
    private static readonly TimeSpan PollInterval = TimeSpan.FromHours(6);
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
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var membershipService = scope.ServiceProvider.GetRequiredService<IUserMembershipService>();
                await membershipService.SendDueExpiryRemindersAsync(ReminderLeadTime, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process due membership expiry reminders.");
            }

            try
            {
                await Task.Delay(PollInterval, stoppingToken);
            }
            catch (OperationCanceledException)
            {
            }
        }
    }
}
