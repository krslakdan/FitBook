using FitBook.Model.Constants;
using FitBook.Model.Requests.Trainings;
using FitBook.Model.Responses.Trainings;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class TrainingsController : BaseCRUDController<TrainingResponse, TrainingSearchObject, TrainingInsertRequest, TrainingUpdateRequest, ITrainingService>
{
    public TrainingsController(ITrainingService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainingResponse>> Insert([FromBody] TrainingInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainingResponse>> Update(int id, [FromBody] TrainingUpdateRequest request, CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }
}
