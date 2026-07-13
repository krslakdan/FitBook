using FitBook.Model.Constants;
using FitBook.Model.Requests.NewsItems;
using FitBook.Model.Responses.NewsItems;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public class NewsItemsController : BaseCRUDController<NewsItemResponse, NewsItemSearchObject, NewsItemInsertRequest, NewsItemUpdateRequest, INewsItemService>
{
    public NewsItemsController(INewsItemService service) : base(service)
    {
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<NewsItemResponse>> Insert([FromBody] NewsItemInsertRequest request, CancellationToken cancellationToken = default)
    {
        return base.Insert(request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<ActionResult<NewsItemResponse>> Update(int id, [FromBody] NewsItemUpdateRequest request, CancellationToken cancellationToken = default)
    {
        return base.Update(id, request, cancellationToken);
    }

    [Authorize(Roles = Roles.Admin)]
    public override Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        return base.Delete(id, cancellationToken);
    }
}
