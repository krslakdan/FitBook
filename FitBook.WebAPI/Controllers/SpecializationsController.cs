using FitBook.Model.Constants;
using FitBook.Model.Requests.Specializations;
using FitBook.Model.Responses.Specializations;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class SpecializationsController : BaseCRUDController<SpecializationResponse, SpecializationSearchObject, SpecializationInsertRequest, SpecializationUpdateRequest, ISpecializationService>
{
    public SpecializationsController(ISpecializationService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<SpecializationResponse>> Insert([FromBody] SpecializationInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<SpecializationResponse>> Update(int id, [FromBody] SpecializationUpdateRequest request, CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }
}
