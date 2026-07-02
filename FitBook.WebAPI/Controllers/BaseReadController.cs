using FitBook.Model.Responses;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public abstract class BaseReadController<TResponse, TSearch, TService> : ControllerBase, IBaseReadController<TResponse, TSearch>
    where TSearch : BaseSearchObject, new()
    where TService : IBaseReadService<TResponse, TSearch>
{
    protected readonly TService Service;

    protected BaseReadController(TService service)
    {
        Service = service;
    }

    [HttpGet]
    public virtual async Task<ActionResult<PagedResult<TResponse>>> GetPaged([FromQuery] TSearch search, CancellationToken cancellationToken = default)
    {
        var result = await Service.GetPagedAsync(search, cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public virtual async Task<ActionResult<TResponse>> GetById(int id, CancellationToken cancellationToken = default)
    {
        var result = await Service.GetByIdAsync(id, cancellationToken);
        return Ok(result);
    }
}
