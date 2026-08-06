using FitBook.Services.Interfaces;
using FitBook.Worker.Services;

namespace FitBook.Worker.BackgroundServices;

public class RefreshTokenCleanupBackgroundService : PollingBackgroundService
{
    public RefreshTokenCleanupBackgroundService(IServiceScopeFactory scopeFactory, DatabaseReadyGate databaseReadyGate, ILogger<RefreshTokenCleanupBackgroundService> logger)
        : base(scopeFactory, databaseReadyGate, logger)
    {
    }

    protected override TimeSpan PollInterval => TimeSpan.FromHours(12);

    protected override TimeSpan FailureRetryInterval => TimeSpan.FromMinutes(5);

    protected override string FailureMessage => "Failed to remove stale refresh tokens.";

    protected override async Task RunIterationAsync(IServiceProvider scopedServices, CancellationToken stoppingToken)
    {
        var cleanupService = scopedServices.GetRequiredService<IRefreshTokenCleanupService>();
        await cleanupService.RemoveStaleRefreshTokensAsync(stoppingToken);
    }
}
