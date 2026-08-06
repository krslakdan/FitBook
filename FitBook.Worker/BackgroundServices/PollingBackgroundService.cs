using FitBook.Worker.Services;

namespace FitBook.Worker.BackgroundServices;

public abstract class PollingBackgroundService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly DatabaseReadyGate _databaseReadyGate;
    private readonly ILogger _logger;

    protected PollingBackgroundService(IServiceScopeFactory scopeFactory, DatabaseReadyGate databaseReadyGate, ILogger logger)
    {
        _scopeFactory = scopeFactory;
        _databaseReadyGate = databaseReadyGate;
        _logger = logger;
    }

    protected abstract TimeSpan PollInterval { get; }

    protected abstract TimeSpan FailureRetryInterval { get; }

    protected abstract string FailureMessage { get; }

    protected abstract Task RunIterationAsync(IServiceProvider scopedServices, CancellationToken stoppingToken);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        try
        {
            await _databaseReadyGate.WaitUntilReadyAsync(stoppingToken);
        }
        catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
        {
            return;
        }

        while (!stoppingToken.IsCancellationRequested)
        {
            var nextDelay = PollInterval;

            try
            {
                using var scope = _scopeFactory.CreateScope();
                await RunIterationAsync(scope.ServiceProvider, stoppingToken);
            }
            catch (Exception ex) when (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogError(ex, "{FailureMessage} Retrying in {Delay}.", FailureMessage, FailureRetryInterval);
                nextDelay = FailureRetryInterval;
            }

            try
            {
                await Task.Delay(nextDelay, stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("{ServiceName} is stopping because the host is shutting down.", GetType().Name);
                break;
            }
        }
    }
}
