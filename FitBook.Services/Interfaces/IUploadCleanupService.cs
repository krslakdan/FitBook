namespace FitBook.Services.Interfaces;

public interface IUploadCleanupService
{
    Task<int> RemoveOrphanedUploadsAsync(CancellationToken cancellationToken = default);
}
