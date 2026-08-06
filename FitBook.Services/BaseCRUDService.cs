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
    : BaseInsertService<TEntity, TResponse, TSearch, TInsertRequest>,
      IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
    where TEntity : BaseEntity
    where TSearch : BaseSearchObject, new()
{
    private readonly IValidator<TUpdateRequest> _updateValidator;

    protected BaseCRUDService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<TInsertRequest> insertValidator,
        IValidator<TUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator)
    {
        _updateValidator = updateValidator;
    }

    public virtual async Task<TResponse> UpdateAsync(int id, TUpdateRequest request, CancellationToken cancellationToken = default)
    {
        await _updateValidator.ValidateAndThrowAsync(request, cancellationToken);

        var entity = await FindWriteEntityByIdAsync(id, cancellationToken);
        if (entity is null)
        {
            throw new NotFoundException(NotFoundMessage);
        }

        await ValidateUpdate(id, request, entity, cancellationToken);
        await BeforeUpdate(id, request, entity, cancellationToken);

        await using (var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken))
        {
            MapUpdateToEntity(request, entity);
            entity.UpdatedAtUtc = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync(cancellationToken);

            await AfterUpdate(id, request, entity, cancellationToken);

            await transaction.CommitAsync(cancellationToken);
        }

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
            throw new NotFoundException(NotFoundMessage);
        }

        await ValidateDelete(id, entity, cancellationToken);
        await BeforeDelete(id, entity, cancellationToken);

        await using (var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken))
        {
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

            await transaction.CommitAsync(cancellationToken);
        }

        _logger.LogInformation(
            "Deleted {EntityType} with id {EntityId}",
            typeof(TEntity).Name,
            id);
    }

    protected virtual IQueryable<TEntity> BuildWriteQuery()
    {
        return ApplyQueryPipeline(BuildQuery(), CreateDefaultSearch(), applySearch: false);
    }

    protected virtual Task<TEntity?> FindWriteEntityByIdAsync(int id, CancellationToken cancellationToken)
    {
        return BuildWriteQuery()
            .FirstOrDefaultAsync(entity => entity.Id == id, cancellationToken);
    }

    protected virtual void MapUpdateToEntity(TUpdateRequest request, TEntity entity)
    {
        _mapper.Map(request, entity);
    }

    protected virtual Task ValidateUpdate(int id, TUpdateRequest request, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task ValidateDelete(int id, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task BeforeUpdate(int id, TUpdateRequest request, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task AfterUpdate(int id, TUpdateRequest request, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task BeforeDelete(int id, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task AfterDelete(int id, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
}
