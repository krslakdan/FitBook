using FitBook.Model.Responses;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public abstract class BaseInsertController<TResponse, TSearch, TInsertRequest, TService>
    : BaseReadController<TResponse, TSearch, TService>
    where TResponse : class, IEntityResponse
    where TSearch : BaseSearchObject, new()
    where TService : IBaseInsertService<TResponse, TSearch, TInsertRequest>
{
    protected BaseInsertController(TService service)
        : base(service)
    {
    }

    [HttpPost]
    [ProducesResponseType(StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public virtual async Task<ActionResult<TResponse>> Insert([FromBody] TInsertRequest request, CancellationToken cancellationToken = default)
    {
        var result = await Service.InsertAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }
}
