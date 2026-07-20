using FitBook.Model.Constants;
using FitBook.Model.Requests.Equipment;
using FitBook.Model.Responses.Equipment;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class EquipmentController : BaseCRUDController<EquipmentResponse, EquipmentSearchObject, EquipmentInsertRequest, EquipmentUpdateRequest, IEquipmentService>
{
    public EquipmentController(IEquipmentService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<EquipmentResponse>> Insert([FromBody] EquipmentInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<EquipmentResponse>> Update(int id, [FromBody] EquipmentUpdateRequest request, CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }
}
