using FitBook.Model.Exceptions;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace FitBook.Services;

public abstract class BaseCRUDService<TEntity, TResponse, TSearch, TInsertRequest, TUpdateRequest>
    : BaseReadService<TEntity, TResponse, TSearch>,
      IBaseCRUDService<TResponse, TSearch, TInsertRequest, TUpdateRequest>
    where TEntity : class
    where TSearch : BaseSearchObject, new()
{
    protected BaseCRUDService(FitBookDbContext dbContext, IMapper mapper)
        : base(dbContext, mapper)
    {
    }

    public virtual async Task<TResponse> InsertAsync(TInsertRequest request, CancellationToken cancellationToken = default)
    {
        await ValidateInsert(request, cancellationToken);

        var entity = MapInsertToEntity(request);
        await BeforeInsert(request, entity, cancellationToken);

        DbContext.Set<TEntity>().Add(entity);
        await DbContext.SaveChangesAsync(cancellationToken);

        await AfterInsert(entity, cancellationToken);
        return entity.Adapt<TResponse>();
    }

    public virtual async Task<TResponse> UpdateAsync(int id, TUpdateRequest request, CancellationToken cancellationToken = default)
    {
        var entity = await BuildWriteQuery()
            .FirstOrDefaultAsync(item => EF.Property<int>(item, "Id") == id, cancellationToken);

        if (entity is null)
        {
            throw new NotFoundException($"{typeof(TEntity).Name} with id {id} was not found.");
        }

        await ValidateUpdate(id, request, entity, cancellationToken);
        await BeforeUpdate(id, request, entity, cancellationToken);

        MapUpdateToEntity(request, entity);
        await DbContext.SaveChangesAsync(cancellationToken);

        await AfterUpdate(id, request, entity, cancellationToken);
        return entity.Adapt<TResponse>();
    }

    public virtual async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await BuildWriteQuery()
            .FirstOrDefaultAsync(item => EF.Property<int>(item, "Id") == id, cancellationToken);

        if (entity is null)
        {
            throw new NotFoundException($"{typeof(TEntity).Name} with id {id} was not found.");
        }

        await ValidateDelete(id, entity, cancellationToken);
        await BeforeDelete(id, entity, cancellationToken);

        if (entity is ISoftDeletable softDeletableEntity)
        {
            softDeletableEntity.IsDeleted = true;
        }
        else
        {
            DbContext.Set<TEntity>().Remove(entity);
        }

        await DbContext.SaveChangesAsync(cancellationToken);
        await AfterDelete(id, entity, cancellationToken);
    }

    protected virtual IQueryable<TEntity> BuildWriteQuery()
    {
        return BuildQuery();
    }

    protected virtual TEntity MapInsertToEntity(TInsertRequest request)
    {
        return request.Adapt<TEntity>();
    }

    protected virtual void MapUpdateToEntity(TUpdateRequest request, TEntity entity)
    {
        request.Adapt(entity);
    }

    protected virtual Task ValidateInsert(TInsertRequest request, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }

    protected virtual Task ValidateUpdate(int id, TUpdateRequest request, TEntity entity, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }

    protected virtual Task ValidateDelete(int id, TEntity entity, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }

    protected virtual Task BeforeInsert(TInsertRequest request, TEntity entity, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }

    protected virtual Task AfterInsert(TEntity entity, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }

    protected virtual Task BeforeUpdate(int id, TUpdateRequest request, TEntity entity, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }

    protected virtual Task AfterUpdate(int id, TUpdateRequest request, TEntity entity, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }

    protected virtual Task BeforeDelete(int id, TEntity entity, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }

    protected virtual Task AfterDelete(int id, TEntity entity, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}
