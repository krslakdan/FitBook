using FitBook.Model.Constants;
using FitBook.Model.Requests.TrainingCategories;
using FitBook.Model.Responses.TrainingCategories;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class TrainingCategoriesController : BaseCRUDController<TrainingCategoryResponse, TrainingCategorySearchObject, TrainingCategoryInsertRequest, TrainingCategoryUpdateRequest, ITrainingCategoryService>
{
    public TrainingCategoriesController(ITrainingCategoryService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainingCategoryResponse>> Insert([FromBody] TrainingCategoryInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<TrainingCategoryResponse>> Update(int id, [FromBody] TrainingCategoryUpdateRequest request, CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }
}
