using FitBook.Services.Interfaces;

namespace FitBook.Worker.BackgroundServices;

public class MembershipExpiryBackgroundService : BackgroundService
{
    private static readonly TimeSpan PollInterval = TimeSpan.FromHours(1);
    private static readonly TimeSpan FailureRetryInterval = TimeSpan.FromSeconds(30);

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<MembershipExpiryBackgroundService> _logger;

    public MembershipExpiryBackgroundService(
        IServiceScopeFactory scopeFactory,
        ILogger<MembershipExpiryBackgroundService> logger)
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
                var expiryService = scope.ServiceProvider.GetRequiredService<IMembershipExpiryService>();
                await expiryService.ExpireDueMembershipsAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to expire due memberships. Retrying in {Delay}.", FailureRetryInterval);
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
