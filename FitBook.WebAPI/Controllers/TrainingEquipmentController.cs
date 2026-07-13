using FitBook.Model.Constants;
using FitBook.Model.Requests.TrainingEquipment;
using FitBook.Model.Responses.TrainingEquipment;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TrainingEquipmentController : BaseCRUDController<TrainingEquipmentResponse, TrainingEquipmentSearchObject, TrainingEquipmentInsertRequest, TrainingEquipmentUpdateRequest, ITrainingEquipmentService>
{
    public TrainingEquipmentController(ITrainingEquipmentService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainingEquipmentResponse>> Insert([FromBody] TrainingEquipmentInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainingEquipmentResponse>> Update(int id, [FromBody] TrainingEquipmentUpdateRequest request, CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }
}
