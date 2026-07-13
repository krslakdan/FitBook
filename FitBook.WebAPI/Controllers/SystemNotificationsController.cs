using FitBook.Model.Responses.SystemNotifications;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class SystemNotificationsController : BaseReadController<SystemNotificationResponse, SystemNotificationSearchObject, ISystemNotificationService>
{
    private readonly ISystemNotificationService _systemNotificationService;

    public SystemNotificationsController(ISystemNotificationService service) : base(service)
    {
        _systemNotificationService = service;
    }

    [HttpPut("{id}/read")]
    public async Task<IActionResult> MarkAsRead(int id, CancellationToken cancellationToken = default)
    {
        await _systemNotificationService.MarkAsReadAsync(id, cancellationToken);
        return NoContent();
    }
}
