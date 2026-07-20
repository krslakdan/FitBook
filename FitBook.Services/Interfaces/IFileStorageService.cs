namespace FitBook.Services.Interfaces;

public interface IFileStorageService
{
    Task<string> SaveImageAsync(
        Stream content,
        string originalFileName,
        string contentType,
        string folder,
        CancellationToken cancellationToken = default);
}
