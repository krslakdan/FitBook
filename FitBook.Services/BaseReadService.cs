using FitBook.Model.Exceptions;
using FitBook.Model.Responses;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public abstract class BaseReadService<TEntity, TResponse, TSearch> : IBaseReadService<TResponse, TSearch>
    where TEntity : BaseEntity
    where TSearch : BaseSearchObject, new()
{
    protected readonly FitBookDbContext _dbContext;
    protected readonly IMapper _mapper;
    protected readonly ILogger _logger;

    protected BaseReadService(FitBookDbContext dbContext, IMapper mapper, ILoggerFactory loggerFactory)
    {
        _dbContext = dbContext;
        _mapper = mapper;
        _logger = loggerFactory.CreateLogger(GetType());
    }

    public virtual async Task<TResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var search = new TSearch();
        var query = ApplyQueryPipeline(BuildQuery(), search, applySearch: false);

        var entity = await query
            .AsNoTracking()
            .FirstOrDefaultAsync(entity => entity.Id == id, cancellationToken);

        if (entity is null)
        {
            throw new NotFoundException($"{typeof(TEntity).Name} with id {id} was not found.");
        }

        return _mapper.Map<TResponse>(entity);
    }

    public virtual async Task<PageResult<TResponse>> GetAllAsync(TSearch? search = null, CancellationToken cancellationToken = default)
    {
        var searchObject = search ?? new TSearch();
        var query = ApplyQueryPipeline(BuildQuery(), searchObject, applySearch: true);
        query = query.OrderBy(entity => entity.Id);

        var skip = (searchObject.Page - 1) * searchObject.PageSize;
        var entities = await query
            .AsNoTracking()
            .Skip(skip)
            .Take(searchObject.PageSize)
            .ToListAsync(cancellationToken);

        int? totalCount = null;
        int? totalPages = null;

        if (searchObject.IncludeTotalCount == true)
        {
            var countQuery = ApplyQueryPipeline(BuildQuery(), searchObject, applySearch: true);
            totalCount = await countQuery.CountAsync(cancellationToken);
            totalPages = totalCount == 0
                ? 0
                : (int)Math.Ceiling(totalCount.Value / (double)searchObject.PageSize);
        }

        return new PageResult<TResponse>
        {
            Page = searchObject.Page,
            PageSize = searchObject.PageSize,
            TotalCount = totalCount,
            TotalPages = totalPages,
            Items = entities.Select(entity => _mapper.Map<TResponse>(entity)).ToList()
        };
    }

    protected virtual IQueryable<TEntity> BuildQuery()
    {
        return _dbContext.Set<TEntity>().AsQueryable();
    }

    protected IQueryable<TEntity> ApplyQueryPipeline(
        IQueryable<TEntity> query,
        TSearch search,
        bool applySearch)
    {
        query = AddInclude(query, search);
        query = ApplyFilter(query, search);

        if (applySearch)
        {
            query = ApplySearch(query, search);
        }

        return query;
    }

    protected virtual IQueryable<TEntity> AddInclude(IQueryable<TEntity> query, TSearch search)
    {
        return query;
    }

    protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search)
    {
        return query;
    }

    protected virtual IQueryable<TEntity> ApplySearch(IQueryable<TEntity> query, TSearch search)
    {
        return query;
    }
}
