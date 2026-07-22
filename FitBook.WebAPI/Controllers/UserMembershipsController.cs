using FitBook.Model.Requests.UserMemberships;
using FitBook.Model.Responses;
using FitBook.Model.Responses.Payments;
using FitBook.Model.Responses.UserMemberships;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class UserMembershipsController
    : BaseCRUDController<
        UserMembershipResponse,
        MembershipSearchObject,
        UserMembershipInsertRequest,
        UserMembershipUpdateRequest,
        IUserMembershipService>
{
    public UserMembershipsController(IUserMembershipService service)
        : base(service)
    {
    }

    [HttpGet]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public override Task<ActionResult<PageResult<UserMembershipResponse>>> GetAll(
        [FromQuery] MembershipSearchObject searchObject,
        CancellationToken cancellationToken = default)
    {
        return base.GetAll(searchObject, cancellationToken);
    }

    [HttpGet("{id:int}")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public override Task<ActionResult<UserMembershipResponse>> GetById(int id, CancellationToken cancellationToken = default)
    {
        return base.GetById(id, cancellationToken);
    }

    [HttpPost]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public override Task<ActionResult<UserMembershipResponse>> Insert(
        [FromBody] UserMembershipInsertRequest request,
        CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [HttpPost("{id:int}/cancel")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<UserMembershipResponse>> Cancel(
        int id, 
        [FromBody] UserMembershipCancelRequest request, 
        CancellationToken cancellationToken = default)
    {
        var result = await Service.CancelAsync(id, request, cancellationToken);
        return Ok(result);
    }

    [HttpPost("{id:int}/payment/intent")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<CreatePaymentIntentResponse>> CreatePaymentIntent(
        int id,
        CancellationToken cancellationToken = default)
    {
        var result = await Service.CreatePaymentIntentAsync(id, cancellationToken);
        return Ok(result);
    }

    [HttpPost("{id:int}/payment/confirm")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<UserMembershipResponse>> ConfirmPayment(
        int id,
        CancellationToken cancellationToken = default)
    {
        var result = await Service.ConfirmPaymentAsync(id, cancellationToken);
        return Ok(result);
    }
}
