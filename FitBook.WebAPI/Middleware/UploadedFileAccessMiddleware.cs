using FitBook.Services.Interfaces;

namespace FitBook.WebAPI.Middleware;

public sealed class UploadedFileAccessMiddleware
{
    public const string UploadsSegment = "/uploads";

    private readonly RequestDelegate _next;
    private readonly ILogger<UploadedFileAccessMiddleware> _logger;

    public UploadedFileAccessMiddleware(RequestDelegate next, ILogger<UploadedFileAccessMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, IFileStorageService fileStorageService)
    {
        if (context.User.Identity?.IsAuthenticated != true)
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            return;
        }

        var requestPath = context.Request.Path.Value ?? string.Empty;
        if (!await fileStorageService.CanCurrentUserAccessAsync(requestPath, context.RequestAborted))
        {
            _logger.LogWarning("Blocked unauthorized access to uploaded file {RequestPath}.", requestPath);
            context.Response.StatusCode = StatusCodes.Status403Forbidden;
            return;
        }

        await _next(context);
    }
}
