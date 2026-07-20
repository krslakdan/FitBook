using FitBook.Model.Exceptions;
using FitBook.Model.Responses.Files;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class FilesController : ControllerBase
{
    private readonly IFileStorageService _fileStorageService;

    public FilesController(IFileStorageService fileStorageService)
    {
        _fileStorageService = fileStorageService;
    }

    [HttpPost("upload")]
    [RequestSizeLimit(6 * 1024 * 1024)]
    public async Task<ActionResult<FileUploadResponse>> Upload(
        IFormFile? file,
        [FromForm] string folder = "users",
        CancellationToken cancellationToken = default)
    {
        if (file is null || file.Length == 0)
        {
            throw new BusinessException("Datoteka je obavezna.");
        }

        await using var stream = file.OpenReadStream();
        var url = await _fileStorageService.SaveImageAsync(
            stream,
            file.FileName,
            file.ContentType,
            folder,
            cancellationToken);

        return Ok(new FileUploadResponse { Url = url });
    }
}
