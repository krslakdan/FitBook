using FitBook.Model.Constants;
using FitBook.Model.Requests.TrainingTerms;
using FitBook.Model.Responses.TrainingTerms;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class TrainingTermsController : BaseCRUDController<TrainingTermResponse, TrainingTermSearchObject, TrainingTermInsertRequest, TrainingTermUpdateRequest, ITrainingTermService>
{
    private readonly ITrainingTermService _trainingTermService;

    public TrainingTermsController(ITrainingTermService service) : base(service)
    {
        _trainingTermService = service;
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainingTermResponse>> Insert([FromBody] TrainingTermInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainingTermResponse>> Update(int id, [FromBody] TrainingTermUpdateRequest request, CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }

    [HttpPost("{id}/cancel")]
    [Authorize(Roles = Roles.Admin + "," + Roles.Trainer)]
    public async Task<TrainingTermResponse> Cancel(int id, [FromBody] TrainingTermCancelRequest request, CancellationToken cancellationToken = default)
    {
        return await _trainingTermService.CancelAsync(id, request, cancellationToken);
    }

    [HttpPost("{id}/complete")]
    [Authorize(Roles = Roles.Admin + "," + Roles.Trainer)]
    public async Task<TrainingTermResponse> Complete(int id, CancellationToken cancellationToken = default)
    {
        return await _trainingTermService.CompleteAsync(id, cancellationToken);
    }
}
