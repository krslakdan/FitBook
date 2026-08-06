using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace FitBook.Services.Files;

public class UploadCleanupService : IUploadCleanupService
{
    private static readonly TimeSpan MinimumAge = TimeSpan.FromHours(24);

    private readonly FitBookDbContext _dbContext;
    private readonly string _rootPath;
    private readonly ILogger<UploadCleanupService> _logger;

    public UploadCleanupService(
        FitBookDbContext dbContext,
        IOptions<FileStorageOptions> options,
        ILogger<UploadCleanupService> logger)
    {
        _dbContext = dbContext;
        _rootPath = options.Value.RootPath;
        _logger = logger;
    }

    public async Task<int> RemoveOrphanedUploadsAsync(CancellationToken cancellationToken = default)
    {
        var uploadsPath = Path.Combine(_rootPath, "uploads");
        if (!Directory.Exists(uploadsPath))
        {
            return 0;
        }

        var referenced = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var url in await _dbContext.UserAccounts.Select(x => x.ProfileImageUrl).ToListAsync(cancellationToken))
        {
            AddReference(referenced, url);
        }

        foreach (var url in await _dbContext.Trainers.Select(x => x.ImageUrl).ToListAsync(cancellationToken))
        {
            AddReference(referenced, url);
        }

        foreach (var url in await _dbContext.NewsItems.Select(x => x.ImageUrl).ToListAsync(cancellationToken))
        {
            AddReference(referenced, url);
        }

        var cutoffUtc = DateTime.UtcNow - MinimumAge;
        var removedCount = 0;

        foreach (var filePath in Directory.EnumerateFiles(uploadsPath, "*", SearchOption.AllDirectories))
        {
            cancellationToken.ThrowIfCancellationRequested();

            var fileName = Path.GetFileName(filePath);
            if (referenced.Contains(fileName))
            {
                continue;
            }

            if (File.GetLastWriteTimeUtc(filePath) > cutoffUtc)
            {
                continue;
            }

            try
            {
                File.Delete(filePath);
                removedCount++;
            }
            catch (IOException ex)
            {
                _logger.LogWarning(ex, "Could not delete orphaned upload {FilePath}.", filePath);
            }
            catch (UnauthorizedAccessException ex)
            {
                _logger.LogWarning(ex, "Could not delete orphaned upload {FilePath}.", filePath);
            }
        }

        if (removedCount > 0)
        {
            _logger.LogInformation("Removed {Count} orphaned uploaded file(s).", removedCount);
        }

        return removedCount;
    }

    private static void AddReference(HashSet<string> referenced, string? url)
    {
        if (string.IsNullOrWhiteSpace(url))
        {
            return;
        }

        referenced.Add(Path.GetFileName(url.Replace('\\', '/')));
    }
}
