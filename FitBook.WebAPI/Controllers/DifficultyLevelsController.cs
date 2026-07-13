using FitBook.Model.Constants;
using FitBook.Model.Requests.DifficultyLevels;
using FitBook.Model.Responses.DifficultyLevels;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class DifficultyLevelsController : BaseCRUDController<DifficultyLevelResponse, DifficultyLevelSearchObject, DifficultyLevelInsertRequest, DifficultyLevelUpdateRequest, IDifficultyLevelService>
{
    public DifficultyLevelsController(IDifficultyLevelService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<DifficultyLevelResponse>> Insert([FromBody] DifficultyLevelInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<DifficultyLevelResponse>> Update(int id, [FromBody] DifficultyLevelUpdateRequest request, CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }
}
