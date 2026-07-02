using FitBook.Model.Responses;
using FitBook.Model.SearchObjects;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

public interface IBaseReadController<TResponse, in TSearch>
    where TSearch : BaseSearchObject
{
    Task<ActionResult<PagedResult<TResponse>>> GetPaged([FromQuery] TSearch search, CancellationToken cancellationToken = default);
    Task<ActionResult<TResponse>> GetById(int id, CancellationToken cancellationToken = default);
}
