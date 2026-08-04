using FitBook.Model.Constants;
using FitBook.Model.Exceptions;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace FitBook.Services.Files;

public class FileStorageService : IFileStorageService
{
    private const long MaxFileSizeBytes = 5 * 1024 * 1024;
    private const string UploadsRoot = "uploads";

    private static readonly string[] AllowedFolders = ["users", "trainers", "news"];
    private static readonly string[] AdminOnlyFolders = ["trainers", "news"];
    private static readonly string[] OwnerScopedFolders = ["users"];

    private static readonly Dictionary<string, string> AllowedContentTypeByExtension = new()
    {
        [".jpg"] = "image/jpeg",
        [".jpeg"] = "image/jpeg",
        [".png"] = "image/png",
        [".webp"] = "image/webp"
    };

    private readonly string _rootPath;
    private readonly ICurrentUserService _currentUserService;
    private readonly FitBookDbContext _dbContext;

    public FileStorageService(
        IOptions<FileStorageOptions> options,
        ICurrentUserService currentUserService,
        FitBookDbContext dbContext)
    {
        _rootPath = options.Value.RootPath;

        if (string.IsNullOrWhiteSpace(_rootPath))
        {
            throw new InvalidOperationException("FileStorageOptions.RootPath nije konfigurisan.");
        }

        _currentUserService = currentUserService;
        _dbContext = dbContext;
    }

    public async Task<bool> CanCurrentUserAccessAsync(string requestPath, CancellationToken cancellationToken = default)
    {
        var normalizedPath = requestPath.Replace('\\', '/').Trim('/');
        var segments = normalizedPath.Split('/', StringSplitOptions.RemoveEmptyEntries);

        if (segments.Length != 3 || !string.Equals(segments[0], UploadsRoot, StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        var folder = segments[1].ToLowerInvariant();
        if (!AllowedFolders.Contains(folder))
        {
            return false;
        }

        if (!OwnerScopedFolders.Contains(folder))
        {
            return true;
        }

        if (_currentUserService.IsAdmin() || _currentUserService.IsInRole(Roles.Trainer))
        {
            return true;
        }

        var currentUserId = _currentUserService.GetRequiredUserId();
        var ownImageUrl = await _dbContext.UserAccounts
            .Where(user => user.Id == currentUserId)
            .Select(user => user.ProfileImageUrl)
            .FirstOrDefaultAsync(cancellationToken);

        return !string.IsNullOrWhiteSpace(ownImageUrl)
            && string.Equals(ownImageUrl.Replace('\\', '/').Trim('/'), normalizedPath, StringComparison.OrdinalIgnoreCase);
    }

    public async Task<string> SaveImageAsync(
        Stream content,
        string originalFileName,
        string contentType,
        string folder,
        CancellationToken cancellationToken = default)
    {
        var normalizedFolder = folder.Trim().ToLowerInvariant();
        if (!AllowedFolders.Contains(normalizedFolder))
        {
            throw new BusinessException($"Folder '{folder}' nije dozvoljen. Dozvoljeni folderi: {string.Join(", ", AllowedFolders)}.");
        }

        if (AdminOnlyFolders.Contains(normalizedFolder) && !_currentUserService.IsAdmin())
        {
            throw new BusinessException("Samo administrator može uploadovati slike u ovaj folder.");
        }

        var extension = Path.GetExtension(originalFileName).ToLowerInvariant();
        if (!AllowedContentTypeByExtension.TryGetValue(extension, out var expectedContentType))
        {
            throw new BusinessException($"Ekstenzija '{extension}' nije dozvoljena. Dozvoljene ekstenzije: {string.Join(", ", AllowedContentTypeByExtension.Keys)}.");
        }

        if (!string.Equals(contentType, expectedContentType, StringComparison.OrdinalIgnoreCase))
        {
            throw new BusinessException($"MIME tip '{contentType}' ne odgovara ekstenziji '{extension}' (očekivan '{expectedContentType}').");
        }

        await using var buffer = new MemoryStream();
        await content.CopyToAsync(buffer, cancellationToken);

        if (buffer.Length == 0)
        {
            throw new BusinessException("Datoteka je prazna.");
        }

        if (buffer.Length > MaxFileSizeBytes)
        {
            throw new BusinessException($"Datoteka je prevelika ({buffer.Length / 1024} KB). Maksimalna dozvoljena veličina je {MaxFileSizeBytes / (1024 * 1024)} MB.");
        }

        var bytes = buffer.ToArray();
        if (!HasValidMagicBytes(bytes, extension))
        {
            throw new BusinessException($"Sadržaj datoteke ne odgovara ekstenziji '{extension}'. Uploadujte ispravnu sliku formata JPG, PNG ili WebP.");
        }

        var fileName = $"{Guid.NewGuid():N}{extension}";
        var directory = Path.Combine(_rootPath, "uploads", normalizedFolder);
        Directory.CreateDirectory(directory);

        var filePath = Path.Combine(directory, fileName);
        await File.WriteAllBytesAsync(filePath, bytes, cancellationToken);

        return $"uploads/{normalizedFolder}/{fileName}";
    }

    private static bool HasValidMagicBytes(byte[] bytes, string extension) => extension switch
    {
        ".jpg" or ".jpeg" => bytes.Length >= 3
            && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF,
        ".png" => bytes.Length >= 8
            && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47
            && bytes[4] == 0x0D && bytes[5] == 0x0A && bytes[6] == 0x1A && bytes[7] == 0x0A,
        ".webp" => bytes.Length >= 12
            && bytes[0] == (byte)'R' && bytes[1] == (byte)'I' && bytes[2] == (byte)'F' && bytes[3] == (byte)'F'
            && bytes[8] == (byte)'W' && bytes[9] == (byte)'E' && bytes[10] == (byte)'B' && bytes[11] == (byte)'P',
        _ => false
    };
}
