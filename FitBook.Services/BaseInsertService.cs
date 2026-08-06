using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public abstract class BaseInsertService<TEntity, TResponse, TSearch, TInsertRequest>
    : BaseReadService<TEntity, TResponse, TSearch>,
      IBaseInsertService<TResponse, TSearch, TInsertRequest>
    where TEntity : BaseEntity
    where TSearch : BaseSearchObject, new()
{
    private readonly IValidator<TInsertRequest> _insertValidator;

    protected BaseInsertService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<TInsertRequest> insertValidator)
        : base(dbContext, mapper, loggerFactory)
    {
        _insertValidator = insertValidator;
    }

    public virtual async Task<TResponse> InsertAsync(TInsertRequest request, CancellationToken cancellationToken = default)
    {
        await _insertValidator.ValidateAndThrowAsync(request, cancellationToken);
        await ValidateInsert(request, cancellationToken);

        var entity = MapInsertToEntity(request);
        ApplyInsertDefaults(entity);
        await BeforeInsert(request, entity, cancellationToken);

        await using (var transaction = await _dbContext.Database.BeginTransactionAsync(cancellationToken))
        {
            _dbContext.Set<TEntity>().Add(entity);
            await _dbContext.SaveChangesAsync(cancellationToken);

            await AfterInsert(entity, cancellationToken);

            await transaction.CommitAsync(cancellationToken);
        }

        _logger.LogInformation(
            "Inserted {EntityType} with id {EntityId}",
            typeof(TEntity).Name,
            entity.Id);

        return _mapper.Map<TResponse>(entity);
    }

    protected virtual TEntity MapInsertToEntity(TInsertRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);
        return _mapper.Map<TEntity>(request);
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
    protected virtual Task BeforeInsert(TInsertRequest request, TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
    protected virtual Task AfterInsert(TEntity entity, CancellationToken cancellationToken) => Task.CompletedTask;
}
