using FitBook.Services.Interfaces;

namespace FitBook.Worker.BackgroundServices;

public class ReservationReminderBackgroundService : BackgroundService
{
    private static readonly TimeSpan PollInterval = TimeSpan.FromMinutes(15);
    private static readonly TimeSpan FailureRetryInterval = TimeSpan.FromSeconds(30);
    private static readonly TimeSpan ReminderLeadTime = TimeSpan.FromHours(24);

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<ReservationReminderBackgroundService> _logger;

    public ReservationReminderBackgroundService(
        IServiceScopeFactory scopeFactory,
        ILogger<ReservationReminderBackgroundService> logger)
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
                await reminderService.SendDueReservationRemindersAsync(ReminderLeadTime, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process due reservation reminders. Retrying in {Delay}.", FailureRetryInterval);
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
