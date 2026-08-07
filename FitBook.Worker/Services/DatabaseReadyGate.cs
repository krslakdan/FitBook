using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace FitBook.Worker.Services;

public sealed class DatabaseReadyGate
{
    private static readonly TimeSpan InitialDelay = TimeSpan.FromSeconds(2);
    private static readonly TimeSpan MaxDelay = TimeSpan.FromSeconds(30);

    private readonly string _connectionString;
    private readonly ILogger<DatabaseReadyGate> _logger;
    private readonly SemaphoreSlim _gate = new(1, 1);
    private volatile bool _isReady;

    public DatabaseReadyGate(IConfiguration configuration, ILogger<DatabaseReadyGate> logger)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection") ?? string.Empty;
        _logger = logger;
    }

    public async Task WaitUntilReadyAsync(CancellationToken cancellationToken)
    {
        if (_isReady)
        {
            return;
        }

        await _gate.WaitAsync(cancellationToken);
        try
        {
            if (_isReady)
            {
                return;
            }

            var delay = InitialDelay;

            while (!cancellationToken.IsCancellationRequested)
            {
                if (await IsMigratedAsync(cancellationToken))
                {
                    _isReady = true;
                    _logger.LogInformation("Database is migrated and reachable. Background services are starting.");
                    return;
                }

                _logger.LogInformation(
                    "Waiting for the API to create and migrate the database. Checking again in {Delay}.",
                    delay);

                await Task.Delay(delay, cancellationToken);
                delay = TimeSpan.FromSeconds(Math.Min(delay.TotalSeconds * 2, MaxDelay.TotalSeconds));
            }
        }
        finally
        {
            _gate.Release();
        }
    }

    private async Task<bool> IsMigratedAsync(CancellationToken cancellationToken)
    {
        try
        {
            await using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync(cancellationToken);

            await using var command = connection.CreateCommand();
            command.CommandText =
                "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '__EFMigrationsHistory'";

            var result = await command.ExecuteScalarAsync(cancellationToken);
            return Convert.ToInt32(result) > 0;
        }
        catch (SqlException)
        {
            return false;
        }
    }
}
