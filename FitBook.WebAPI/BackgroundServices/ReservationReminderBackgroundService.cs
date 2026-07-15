using FitBook.Services.Interfaces;

namespace FitBook.WebAPI.BackgroundServices;

public class ReservationReminderBackgroundService : BackgroundService
{
    private static readonly TimeSpan PollInterval = TimeSpan.FromMinutes(15);
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
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var reservationService = scope.ServiceProvider.GetRequiredService<IReservationService>();
                await reservationService.SendDueRemindersAsync(ReminderLeadTime, stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process due reservation reminders.");
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
