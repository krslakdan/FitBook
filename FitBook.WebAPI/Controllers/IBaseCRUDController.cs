using FitBook.Model.SearchObjects;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public interface IBaseCRUDController<TResponse, in TSearch, in TInsertRequest, in TUpdateRequest>
    : IBaseReadController<TResponse, TSearch>
    where TSearch : BaseSearchObject
{
    Task<ActionResult<TResponse>> Insert([FromBody] TInsertRequest request, CancellationToken cancellationToken = default);
    Task<ActionResult<TResponse>> Update(int id, [FromBody] TUpdateRequest request, CancellationToken cancellationToken = default);
    Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default);
}
