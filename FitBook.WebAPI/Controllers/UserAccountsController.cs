using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses.UserAccounts;
using FitBook.Model.SearchObjects;
using FitBook.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FitBook.WebAPI.Controllers;

public class UserAccountsController
    : BaseCRUDController<
        UserAccountResponse,
        UserSearchObject,
        UserAccountInsertRequest,
        UserAccountUpdateRequest,
        IUserAccountService>
{
    public UserAccountsController(IUserAccountService service)
        : base(service)
    {
    }

    [HttpPut("{id:int}/password/admin-reset")]
    [Authorize(Roles = "Admin")]
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
        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        await Service.ChangeOwnPasswordAsync(userId, request, cancellationToken);
        return NoContent();
    }
}
