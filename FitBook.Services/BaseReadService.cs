using System.Linq.Dynamic.Core;
using System.Linq.Expressions;
using FitBook.Model.Responses;
using FitBook.Model.Enums;
using FitBook.Model.Exceptions;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace FitBook.Services;

public abstract class BaseReadService<TEntity, TResponse, TSearch> : IBaseReadService<TResponse, TSearch>
    where TEntity : class
    where TSearch : BaseSearchObject, new()
{
    protected readonly FitBookDbContext DbContext;
    protected readonly IMapper Mapper;

    protected BaseReadService(FitBookDbContext dbContext, IMapper mapper)
    {
        DbContext = dbContext;
        Mapper = mapper;
    }

    public virtual async Task<TResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        var search = new TSearch();
        var query = BuildQuery();
        query = AddInclude(query, search);
        query = AddFilter(query, search);
        query = query.AsNoTracking().Where(entity => EF.Property<int>(entity, "Id") == id);

        var item = await query
            .ProjectToType<TResponse>()
            .FirstOrDefaultAsync(cancellationToken);

        if (item is null)
        {
            throw new NotFoundException($"{typeof(TEntity).Name} with id {id} was not found.");
        }

        return item;
    }

    public virtual async Task<FitBook.Model.Responses.PagedResult<TResponse>> GetPagedAsync(TSearch? search = null, CancellationToken cancellationToken = default)
    {
        var searchObject = search ?? new TSearch();
        var query = BuildQuery();

        query = AddInclude(query, searchObject);
        query = AddFilter(query, searchObject);
        query = ApplySearch(query, searchObject);
        query = query.AsNoTracking();

        var totalCount = await query.CountAsync(cancellationToken);
        query = ApplySorting(query, searchObject);

        var skip = (searchObject.Page - 1) * searchObject.PageSize;
        var items = await query
            .Skip(skip)
            .Take(searchObject.PageSize)
            .ProjectToType<TResponse>()
            .ToListAsync(cancellationToken);

        return new FitBook.Model.Responses.PagedResult<TResponse>
        {
            Page = searchObject.Page,
            PageSize = searchObject.PageSize,
            TotalCount = totalCount,
            TotalPages = totalCount == 0 ? 0 : (int)Math.Ceiling(totalCount / (double)searchObject.PageSize),
            Items = items
        };
    }

    protected virtual IQueryable<TEntity> BuildQuery()
    {
        return DbContext.Set<TEntity>().AsQueryable();
    }

    protected virtual IQueryable<TEntity> AddInclude(IQueryable<TEntity> query, TSearch search)
    {
        return query;
    }

    protected virtual IQueryable<TEntity> AddFilter(IQueryable<TEntity> query, TSearch search)
    {
        return query;
    }

    protected virtual IReadOnlyDictionary<string, string> BuildSortMappings()
    {
        return new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
    }

    protected virtual IQueryable<TEntity> ApplySearch(IQueryable<TEntity> query, TSearch search)
    {
        if (string.IsNullOrWhiteSpace(search.Search))
        {
            return query;
        }

        var stringProperties = typeof(TEntity)
            .GetProperties()
            .Where(property => property.PropertyType == typeof(string))
            .ToArray();

        if (stringProperties.Length == 0)
        {
            return query;
        }

        var searchTerm = search.Search.Trim().ToLowerInvariant();
        var parameter = Expression.Parameter(typeof(TEntity), "entity");
        Expression? body = null;

        foreach (var property in stringProperties)
        {
            var memberExpression = Expression.Property(parameter, property);
            var notNullExpression = Expression.NotEqual(memberExpression, Expression.Constant(null, typeof(string)));
            var lowerExpression = Expression.Call(memberExpression, nameof(string.ToLower), Type.EmptyTypes);
            var containsExpression = Expression.Call(lowerExpression, nameof(string.Contains), Type.EmptyTypes, Expression.Constant(searchTerm));
            var safeContainsExpression = Expression.AndAlso(notNullExpression, containsExpression);
            body = body is null ? safeContainsExpression : Expression.OrElse(body, safeContainsExpression);
        }

        var predicate = Expression.Lambda<Func<TEntity, bool>>(body!, parameter);
        return query.Where(predicate);
    }

    private IQueryable<TEntity> ApplySorting(IQueryable<TEntity> query, TSearch search)
    {
        var sortExpression = BuildSortExpression(search);
        if (string.IsNullOrWhiteSpace(sortExpression))
        {
            return HasPropertyPath(typeof(TEntity), "Id") ? query.OrderBy("Id") : query;
        }

        return query.OrderBy(sortExpression);
    }

    private string BuildSortExpression(TSearch search)
    {
        if (string.IsNullOrWhiteSpace(search.SortBy))
        {
            return string.Empty;
        }

        var clauses = new List<string>();
        var mappings = BuildSortMappings();
        var tokens = search.SortBy.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

        foreach (var token in tokens)
        {
            var (fieldToken, isDescendingFromToken) = ParseSortToken(token);

            if (!TryResolveSortField(fieldToken, mappings, out var mappedField))
            {
                continue;
            }

            var isDescending = isDescendingFromToken ?? search.SortDirection == SortDirection.Desc;
            clauses.Add($"{mappedField} {(isDescending ? "descending" : "ascending")}");
        }

        return string.Join(", ", clauses);
    }

    private static (string Field, bool? IsDescending) ParseSortToken(string token)
    {
        var trimmed = token.Trim();
        if (trimmed.StartsWith('-'))
        {
            return (trimmed[1..], true);
        }

        var parts = trimmed.Split(':', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        if (parts.Length == 2)
        {
            var direction = parts[1].Equals("desc", StringComparison.OrdinalIgnoreCase) ||
                            parts[1].Equals("descending", StringComparison.OrdinalIgnoreCase);
            return (parts[0], direction);
        }

        return (trimmed, null);
    }

    private static bool TryResolveSortField(string field, IReadOnlyDictionary<string, string> mappings, out string resolvedField)
    {
        if (mappings.TryGetValue(field, out var mappedField))
        {
            resolvedField = mappedField;
            return true;
        }

        if (HasPropertyPath(typeof(TEntity), field))
        {
            resolvedField = field;
            return true;
        }

        resolvedField = string.Empty;
        return false;
    }

    private static bool HasPropertyPath(Type rootType, string propertyPath)
    {
        var type = rootType;
        var segments = propertyPath.Split('.', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        if (segments.Length == 0)
        {
            return false;
        }

        foreach (var segment in segments)
        {
            var property = type.GetProperty(segment);
            if (property is null)
            {
                return false;
            }

            type = property.PropertyType;
        }

        return true;
    }
}
