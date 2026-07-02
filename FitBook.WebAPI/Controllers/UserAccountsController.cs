using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses;
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

    [HttpGet]
    [ProducesResponseType(typeof(PageResult<UserAccountResponse>), StatusCodes.Status200OK)]
    public override Task<ActionResult<PageResult<UserAccountResponse>>> GetAll([FromQuery] UserSearchObject search, CancellationToken cancellationToken = default)
        => base.GetAll(search, cancellationToken);

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(UserAccountResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public override Task<ActionResult<UserAccountResponse>> GetById(int id, CancellationToken cancellationToken = default)
        => base.GetById(id, cancellationToken);

    [HttpPost]
    [ProducesResponseType(typeof(UserAccountResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public override Task<ActionResult<UserAccountResponse>> Insert([FromBody] UserAccountInsertRequest request, CancellationToken cancellationToken = default)
        => base.Insert(request, cancellationToken);

    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(UserAccountResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public override Task<ActionResult<UserAccountResponse>> Update(int id, [FromBody] UserAccountUpdateRequest request, CancellationToken cancellationToken = default)
        => base.Update(id, request, cancellationToken);

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
        => base.Delete(id, cancellationToken);

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
