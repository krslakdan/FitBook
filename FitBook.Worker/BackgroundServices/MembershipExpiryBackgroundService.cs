using FitBook.Services.Interfaces;
using FitBook.Worker.Services;

namespace FitBook.Worker.BackgroundServices;

public class MembershipExpiryBackgroundService : PollingBackgroundService
{
    public MembershipExpiryBackgroundService(IServiceScopeFactory scopeFactory, DatabaseReadyGate databaseReadyGate, ILogger<MembershipExpiryBackgroundService> logger)
        : base(scopeFactory, databaseReadyGate, logger)
    {
    }

    protected override TimeSpan PollInterval => TimeSpan.FromHours(1);

    protected override TimeSpan FailureRetryInterval => TimeSpan.FromSeconds(30);

    protected override string FailureMessage => "Failed to expire due memberships.";

    protected override async Task RunIterationAsync(IServiceProvider scopedServices, CancellationToken stoppingToken)
    {
        var expiryService = scopedServices.GetRequiredService<IMembershipExpiryService>();
        await expiryService.ExpireDueMembershipsAsync(stoppingToken);
    }
}
