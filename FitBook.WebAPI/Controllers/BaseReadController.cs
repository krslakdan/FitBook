using FitBook.Model.Responses;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FitBook.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public abstract class BaseReadController<TResponse, TSearch, TService> : ControllerBase
    where TSearch : BaseSearchObject, new()
    where TService : IBaseReadService<TResponse, TSearch>
{
    protected readonly TService Service;

    protected BaseReadController(TService service)
    {
        Service = service;
    }

    [HttpGet]
    [ProducesResponseType(StatusCodes.Status200OK)]
    // Parametar se NE smije zvati "search": kolidira sa ?search= query
    // parametrom i prebacuje model binder u prefiksni mod (search.Page...),
    // čime svi filteri prestaju da se vezuju.
    public virtual async Task<ActionResult<PageResult<TResponse>>> GetAll([FromQuery] TSearch searchObject, CancellationToken cancellationToken = default)
    {
        var result = await Service.GetAllAsync(searchObject, cancellationToken);
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public virtual async Task<ActionResult<TResponse>> GetById(int id, CancellationToken cancellationToken = default)
    {
        var result = await Service.GetByIdAsync(id, cancellationToken);
        return Ok(result);
    }
}
