using FitBook.Model.Exceptions;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public abstract class BaseCRUDService<TEntity, TResponse, TSearch, TInsertRequest, TUpdateRequest>
    : BaseReadService<TEntity, TResponse, TSearch>,
      IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
    where TEntity : BaseEntity
    where TSearch : BaseSearchObject, new()
{
    private readonly IValidator<TInsertRequest> _insertValidator;
    private readonly IValidator<TUpdateRequest> _updateValidator;

    protected BaseCRUDService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<TInsertRequest> insertValidator,
        IValidator<TUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory)
    {
        _insertValidator = insertValidator;
        _updateValidator = updateValidator;
    }

    public virtual async Task<TResponse> InsertAsync(TInsertRequest request, CancellationToken cancellationToken = default)
    {
        await _insertValidator.ValidateAndThrowAsync(request, cancellationToken);
        await ValidateInsert(request, cancellationToken);

        var entity = MapInsertToEntity(request);
        ApplyInsertDefaults(entity);
        await BeforeInsert(request, entity, cancellationToken);

        _dbContext.Set<TEntity>().Add(entity);
        await _dbContext.SaveChangesAsync(cancellationToken);

        await AfterInsert(entity, cancellationToken);
        _logger.LogInformation(
            "Inserted {EntityType} with id {EntityId}",
            typeof(TEntity).Name,
            entity.Id);

        return _mapper.Map<TResponse>(entity);
    }

    public virtual async Task<TResponse> UpdateAsync(int id, TUpdateRequest request, CancellationToken cancellationToken = default)
    {
        await _updateValidator.ValidateAndThrowAsync(request, cancellationToken);

        var entity = await FindWriteEntityByIdAsync(id, cancellationToken);
        if (entity is null)
        {
            throw new NotFoundException($"{typeof(TEntity).Name} with id {id} was not found.");
        }

        await ValidateUpdate(id, request, entity, cancellationToken);
        await BeforeUpdate(id, request, entity, cancellationToken);

        MapUpdateToEntity(request, entity);
        entity.UpdatedAtUtc = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);

        await AfterUpdate(id, request, entity, cancellationToken);
        _logger.LogInformation(
            "Updated {EntityType} with id {EntityId}",
            typeof(TEntity).Name,
            id);

        return _mapper.Map<TResponse>(entity);
    }

    public virtual async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await FindWriteEntityByIdAsync(id, cancellationToken);
        if (entity is null)
        {
            throw new NotFoundException($"{typeof(TEntity).Name} with id {id} was not found.");
        }

        await ValidateDelete(id, entity, cancellationToken);
        await BeforeDelete(id, entity, cancellationToken);

        if (entity is ISoftDeletable softDeletableEntity)
        {
            softDeletableEntity.IsDeleted = true;
            entity.UpdatedAtUtc = DateTime.UtcNow;
        }
        else
        {
            _dbContext.Set<TEntity>().Remove(entity);
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        await AfterDelete(id, entity, cancellationToken);
        _logger.LogInformation(
            "Deleted {EntityType} with id {EntityId}",
            typeof(TEntity).Name,
            id);
    }

    protected virtual IQueryable<TEntity> BuildWriteQuery()
    {
        return ApplyQueryPipeline(BuildQuery(), new TSearch(), applySearch: false);
    }

    protected virtual Task<TEntity?> FindWriteEntityByIdAsync(int id, CancellationToken cancellationToken)
    {
        return BuildWriteQuery()
            .FirstOrDefaultAsync(entity => entity.Id == id, cancellationToken);
    }

    protected virtual TEntity MapInsertToEntity(TInsertRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);
        return _mapper.Map<TEntity>(request);
    }

    protected virtual void MapUpdateToEntity(TUpdateRequest request, TEntity entity)
    {
        _mapper.Map(request, entity);
    }

    protected virtual void ApplyInsertDefaults(TEntity entity)
    {
        entity.CreatedAtUtc = DateTime.UtcNow;
        entity.UpdatedAtUtc = null;

        if (entity is ISoftDeletable softDeletableEntity)
        {
            softDeletableEntity.IsDeleted = false;
        }
    }

    protected virtual Task ValidateInsert(TInsertRequest request, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task ValidateUpdate(int id, TUpdateRequest request, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task ValidateDelete(int id, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task BeforeInsert(TInsertRequest request, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task AfterInsert(TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task BeforeUpdate(int id, TUpdateRequest request, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task AfterUpdate(int id, TUpdateRequest request, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task BeforeDelete(int id, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task AfterDelete(int id, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
}
