using FitBook.Model.Constants;
using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses;
using FitBook.Model.Responses.UserAccounts;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class UserAccountsController
    : BaseCRUDController<
        UserAccountResponse,
        UserSearchObject,
        UserAccountInsertRequest,
        UserAccountUpdateRequest,
        IUserAccountService>
{
    private readonly ICurrentUserService _currentUserService;

    public UserAccountsController(IUserAccountService service, ICurrentUserService currentUserService)
        : base(service)
    {
        _currentUserService = currentUserService;
    }

    [HttpGet]
    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<PageResult<UserAccountResponse>>> GetAll([FromQuery] UserSearchObject search, CancellationToken cancellationToken = default)
    {
        return base.GetAll(search, cancellationToken);
    }

    [HttpGet("{id:int}")]
    [Authorize]
    public override async Task<ActionResult<UserAccountResponse>> GetById(int id, CancellationToken cancellationToken = default)
    {
        var currentUserId = _currentUserService.GetRequiredUserId();
        if (!_currentUserService.IsAdmin() && currentUserId != id)
        {
            return Forbid();
        }
        return await base.GetById(id, cancellationToken);
    }

    [HttpPost]
    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<UserAccountResponse>> Insert([FromBody] UserAccountInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [HttpPut("{id:int}")]
    [Authorize]
    public override async Task<ActionResult<UserAccountResponse>> Update(int id, [FromBody] UserAccountUpdateRequest request, CancellationToken cancellationToken = default)
    {
        var currentUserId = _currentUserService.GetRequiredUserId();
        var isAdmin = _currentUserService.IsAdmin();
        
        if (!isAdmin && currentUserId != id)
        {
            return Forbid();
        }

        if (!isAdmin)
        {
            request.Role = null;
            request.IsActive = null;
        }

        return await base.Update(id, request, cancellationToken);
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }

    [HttpPut("{id:int}/password/admin-reset")]
    [Authorize(Roles = Roles.Admin)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> AdminResetPassword(int id, [FromBody] UserAccountAdminPasswordResetRequest request, CancellationToken cancellationToken = default)
    {
        await Service.AdminResetPasswordAsync(id, request, cancellationToken);
        return NoContent();
    }

    [HttpPut("me/password")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ChangeOwnPassword([FromBody] UserAccountChangeOwnPasswordRequest request, CancellationToken cancellationToken = default)
    {
        var userId = _currentUserService.GetRequiredUserId();

        await Service.ChangeOwnPasswordAsync(userId, request, cancellationToken);
        return NoContent();
    }
}
