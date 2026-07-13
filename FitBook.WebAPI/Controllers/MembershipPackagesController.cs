using FitBook.Model.Constants;
using FitBook.Model.Requests.MembershipPackages;
using FitBook.Model.Responses;
using FitBook.Model.Responses.MembershipPackages;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class MembershipPackagesController
    : BaseCRUDController<
        MembershipPackageResponse,
        MembershipPackageSearchObject,
        MembershipPackageInsertRequest,
        MembershipPackageUpdateRequest,
        IMembershipPackageService>
{
    public MembershipPackagesController(IMembershipPackageService service)
        : base(service)
    {
    }

    [HttpGet]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public override Task<ActionResult<PageResult<MembershipPackageResponse>>> GetAll(
        [FromQuery] MembershipPackageSearchObject search,
        CancellationToken cancellationToken = default)
    {
        return base.GetAll(search, cancellationToken);
    }

    [HttpGet("{id:int}")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public override Task<ActionResult<MembershipPackageResponse>> GetById(int id, CancellationToken cancellationToken = default)
    {
        return base.GetById(id, cancellationToken);
    }

    [HttpPost]
    [Authorize(Roles = Roles.Admin)]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public override Task<ActionResult<MembershipPackageResponse>> Insert(
        [FromBody] MembershipPackageInsertRequest request,
        CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public override Task<ActionResult<MembershipPackageResponse>> Update(
        int id,
        [FromBody] MembershipPackageUpdateRequest request,
        CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }
}
