using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public abstract class BaseCRUDController<TResponse, TSearch, TInsertRequest, TUpdateRequest, TService>
    : BaseReadController<TResponse, TSearch, TService>,
      IBaseCRUDController<TResponse, TSearch, TInsertRequest, TUpdateRequest>
    where TSearch : BaseSearchObject, new()
    where TService : IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
{
    protected BaseCRUDController(TService service)
        : base(service)
    {
    }

    [HttpPost]
    public virtual async Task<ActionResult<TResponse>> Insert([FromBody] TInsertRequest request, CancellationToken cancellationToken = default)
    {
        var result = await Service.InsertAsync(request, cancellationToken);
        return CreatedAtAction(nameof(GetById), new { id = ResolveIdFromResponse(result) }, result);
    }

    [HttpPut("{id:int}")]
    public virtual async Task<ActionResult<TResponse>> Update(int id, [FromBody] TUpdateRequest request, CancellationToken cancellationToken = default)
    {
        var result = await Service.UpdateAsync(id, request, cancellationToken);
        return Ok(result);
    }

    [HttpDelete("{id:int}")]
    public virtual async Task<IActionResult> Delete(int id, CancellationToken cancellationToken = default)
    {
        await Service.DeleteAsync(id, cancellationToken);
        return NoContent();
    }

    protected virtual int ResolveIdFromResponse(TResponse response)
    {
        var idProperty = typeof(TResponse).GetProperty("Id");
        if (idProperty is null)
        {
            return 0;
        }

        var idValue = idProperty.GetValue(response);
        return idValue is int id ? id : 0;
    }
}
