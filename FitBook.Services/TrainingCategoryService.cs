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

    protected override async Task ValidateDelete(int id, TrainingCategory entity, CancellationToken cancellationToken)
    {
        var isUsed = await _dbContext.Trainings
            .AnyAsync(x => x.TrainingCategoryId == id, cancellationToken);

        if (isUsed)
        {
            throw new BusinessException($"Kategorija treninga '{entity.Name}' ne može biti obrisana jer postoje treninzi koji je koriste. Označite je kao neaktivnu umjesto brisanja.");
        }
    }
}
