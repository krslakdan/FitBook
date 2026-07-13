using FitBook.Model.Constants;
using FitBook.Model.Exceptions;
using FitBook.Model.Requests.Trainers;
using FitBook.Model.Responses.Trainers;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class TrainerService
    : BaseCRUDService<Trainer, TrainerResponse, TrainerSearchObject, TrainerInsertRequest, TrainerUpdateRequest>,
      ITrainerService
{
    public TrainerService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<TrainerInsertRequest> insertValidator,
        IValidator<TrainerUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
    }

    protected override IQueryable<Trainer> ApplyFilter(IQueryable<Trainer> query, TrainerSearchObject search)
    {
        if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        if (search.IsAvailable.HasValue)
        {
            query = query.Where(x => x.IsAvailable == search.IsAvailable.Value);
        }

        return query;
    }

    protected override IQueryable<Trainer> ApplySearch(IQueryable<Trainer> query, TrainerSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Search))
        {
            var term = search.Search.Trim().ToLowerInvariant();
            query = query.Where(x =>
                x.FirstName.ToLower().Contains(term) ||
                x.LastName.ToLower().Contains(term) ||
                x.Specialization.ToLower().Contains(term));
        }

        return query;
    }

    protected override async Task ValidateInsert(TrainerInsertRequest request, CancellationToken cancellationToken)
    {
        // Verify the UserAccount exists and has the Trainer role
        var userAccount = await _dbContext.UserAccounts
            .FirstOrDefaultAsync(u => u.Id == request.UserAccountId && !u.IsDeleted, cancellationToken);

        if (userAccount is null)
        {
            throw new NotFoundException($"UserAccount with id {request.UserAccountId} was not found.");
        }

        if (userAccount.Role != Roles.Trainer)
        {
            throw new BusinessException($"Korisnički račun s id {request.UserAccountId} nema ulogu Trenera. Dodijelite korisniku ulogu Trenera prije kreiranja trenerskog profila.");
        }

        // Verify no duplicate Trainer record for this UserAccount
        var duplicateExists = await _dbContext.Trainers
            .AnyAsync(t => t.UserAccountId == request.UserAccountId, cancellationToken);

        if (duplicateExists)
        {
            throw new BusinessException($"Korisnički račun s id {request.UserAccountId} već ima kreiran trenerski profil.");
        }
    }

    protected override async Task ValidateDelete(int id, Trainer entity, CancellationToken cancellationToken)
    {
        var hasTerms = await _dbContext.TrainingTerms
            .AnyAsync(t => t.TrainerId == id, cancellationToken);

        if (hasTerms)
        {
            throw new BusinessException($"Trener '{entity.FirstName} {entity.LastName}' ne može biti obrisan jer postoje termini treninga vezani za njega. Označite ga kao neaktivnog umjesto brisanja.");
        }
    }
}
