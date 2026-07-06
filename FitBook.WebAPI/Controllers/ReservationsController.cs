using FitBook.Model.Constants;
using FitBook.Model.Requests.Reservations;
using FitBook.Model.Responses;
using FitBook.Model.Responses.Reservations;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class ReservationsController
    : BaseCRUDController<
        ReservationResponse,
        ReservationSearchObject,
        ReservationInsertRequest,
        ReservationUpdateRequest,
        IReservationService>
{
    private readonly ICurrentUserService _currentUserService;

    public ReservationsController(IReservationService service, ICurrentUserService currentUserService)
        : base(service)
    {
        _currentUserService = currentUserService;
    }

    [HttpGet]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public override Task<ActionResult<PageResult<ReservationResponse>>> GetAll(
        [FromQuery] ReservationSearchObject search,
        CancellationToken cancellationToken = default)
    {
        return base.GetAll(search, cancellationToken);
    }

    [HttpGet("{id:int}")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public override Task<ActionResult<ReservationResponse>> GetById(int id, CancellationToken cancellationToken = default)
    {
        return base.GetById(id, cancellationToken);
    }

    [HttpPost]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public override Task<ActionResult<ReservationResponse>> Insert(
        [FromBody] ReservationInsertRequest request,
        CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [HttpPut("{id:int}")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status405MethodNotAllowed)]
    public override Task<ActionResult<ReservationResponse>> Update(
        int id,
        [FromBody] ReservationUpdateRequest request,
        CancellationToken cancellationToken = default)
    {
        return Task.FromResult<ActionResult<ReservationResponse>>(
            StatusCode(StatusCodes.Status405MethodNotAllowed,
                "Generički update rezervacije nije dozvoljen. Koristite /confirm, /cancel ili /complete."));
    }

    [HttpDelete("{id:int}")]
    [Authorize]
    [ProducesResponseType(StatusCodes.Status405MethodNotAllowed)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return Task.FromResult<IActionResult>(
            StatusCode(StatusCodes.Status405MethodNotAllowed,
                "Rezervacije se ne brišu. Status se mijenja kroz namjenske endpointe."));
    }

    [HttpPost("{id:int}/confirm")]
    [Authorize(Roles = Roles.Admin)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ReservationResponse>> Confirm(int id, CancellationToken cancellationToken = default)
    {
        var result = await Service.ConfirmAsync(id, cancellationToken);
        return Ok(result);
    }

    [HttpPost("{id:int}/cancel")]
    [Authorize]
    public async Task<ActionResult<ReservationResponse>> Cancel(int id, [FromBody] ReservationCancelRequest request, CancellationToken cancellationToken = default)
    {
        var result = await Service.CancelAsync(id, request, cancellationToken);
        return Ok(result);
    }

    [HttpPost("{id:int}/complete")]
    [Authorize(Roles = Roles.Admin)]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ReservationResponse>> Complete(int id, CancellationToken cancellationToken = default)
    {
        var result = await Service.CompleteAsync(id, cancellationToken);
        return Ok(result);
    }
}
