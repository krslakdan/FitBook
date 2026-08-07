using FitBook.Model.Exceptions;
using FitBook.Model.Requests.TrainingCategories;
using FitBook.Model.Responses.TrainingCategories;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class TrainingCategoryService
    : BaseCRUDService<TrainingCategory, TrainingCategoryResponse, TrainingCategorySearchObject, TrainingCategoryInsertRequest, TrainingCategoryUpdateRequest>,
      ITrainingCategoryService
{
    public TrainingCategoryService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<TrainingCategoryInsertRequest> insertValidator,
        IValidator<TrainingCategoryUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
    }

    protected override IQueryable<TrainingCategory> ApplyFilter(IQueryable<TrainingCategory> query, TrainingCategorySearchObject search)
    {
        if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        return query;
    }

    protected override IQueryable<TrainingCategory> ApplySearch(IQueryable<TrainingCategory> query, TrainingCategorySearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Search))
        {
            var term = search.Search.Trim().ToLowerInvariant();
            query = query.Where(x => x.Name.ToLower().Contains(term));
        }

        return query;
    }

    protected override Task ValidateInsert(TrainingCategoryInsertRequest request, CancellationToken cancellationToken)
        => EnsureNameIsUniqueAsync(request.Name, null, cancellationToken);

    protected override Task ValidateUpdate(int id, TrainingCategoryUpdateRequest request, TrainingCategory entity, CancellationToken cancellationToken)
        => EnsureNameIsUniqueAsync(request.Name, id, cancellationToken);

    protected override Task BeforeInsert(TrainingCategoryInsertRequest request, TrainingCategory entity, CancellationToken cancellationToken)
    {
        entity.Name = entity.Name.Trim();
        return Task.CompletedTask;
    }

    protected override Task BeforeUpdate(int id, TrainingCategoryUpdateRequest request, TrainingCategory entity, CancellationToken cancellationToken)
    {
        request.Name = request.Name.Trim();
        return Task.CompletedTask;
    }

    private async Task EnsureNameIsUniqueAsync(string name, int? excludeId, CancellationToken cancellationToken)
    {
        var normalized = name.Trim().ToLowerInvariant();
        var duplicateExists = await _dbContext.TrainingCategories
            .AnyAsync(x => x.Name.ToLower() == normalized && (excludeId == null || x.Id != excludeId.Value), cancellationToken);

        if (duplicateExists)
        {
            throw new BusinessException($"Kategorija treninga sa nazivom '{name.Trim()}' već postoji.");
        }
    }

    protected override async Task ValidateDelete(int id, TrainingCategory entity, CancellationToken cancellationToken)
    {
        var isUsed = await _dbContext.Trainings
            .AnyAsync(x => x.TrainingCategoryId == id, cancellationToken);

        if (isUsed)
        {
            throw new BusinessException($"Kategorija treninga '{entity.Name}' ne može biti obrisana jer postoje treninzi koji je koriste. Označite je kao neaktivnu umjesto brisanja.");
        }
    }

    protected override string NotFoundMessage => "Kategorija treninga nije pronađena.";
}
