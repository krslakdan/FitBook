using FitBook.Model.Constants;
using FitBook.Model.Requests.Trainers;
using FitBook.Model.Responses.Trainers;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class TrainersController : BaseCRUDController<TrainerResponse, TrainerSearchObject, TrainerInsertRequest, TrainerUpdateRequest, ITrainerService>
{
    public TrainersController(ITrainerService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainerResponse>> Insert([FromBody] TrainerInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainerResponse>> Update(int id, [FromBody] TrainerUpdateRequest request, CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }
}
