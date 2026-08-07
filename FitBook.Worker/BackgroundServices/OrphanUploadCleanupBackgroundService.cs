using FitBook.Services.Interfaces;
using FitBook.Worker.Services;

namespace FitBook.Worker.BackgroundServices;

public class OrphanUploadCleanupBackgroundService : PollingBackgroundService
{
    public OrphanUploadCleanupBackgroundService(IServiceScopeFactory scopeFactory, DatabaseReadyGate databaseReadyGate, ILogger<OrphanUploadCleanupBackgroundService> logger)
        : base(scopeFactory, databaseReadyGate, logger)
    {
    }

    protected override TimeSpan PollInterval => TimeSpan.FromHours(12);

    protected override TimeSpan FailureRetryInterval => TimeSpan.FromMinutes(30);

    protected override string FailureMessage => "Failed to remove orphaned uploaded files.";

    protected override async Task RunIterationAsync(IServiceProvider scopedServices, CancellationToken stoppingToken)
    {
        var cleanupService = scopedServices.GetRequiredService<IUploadCleanupService>();
        await cleanupService.RemoveOrphanedUploadsAsync(stoppingToken);
    }
}
