using FitBook.Model.Exceptions;
using FitBook.Model.Requests.TrainingEquipment;
using FitBook.Model.Responses.TrainingEquipment;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using TrainingEquipmentEntity = FitBook.Services.Database.Entities.TrainingEquipment;

namespace FitBook.Services;

public class TrainingEquipmentService
    : BaseCRUDService<TrainingEquipmentEntity, TrainingEquipmentResponse, TrainingEquipmentSearchObject, TrainingEquipmentInsertRequest, TrainingEquipmentUpdateRequest>,
      ITrainingEquipmentService
{
    public TrainingEquipmentService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<TrainingEquipmentInsertRequest> insertValidator,
        IValidator<TrainingEquipmentUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
    }

    protected override IQueryable<TrainingEquipmentEntity> ApplyFilter(IQueryable<TrainingEquipmentEntity> query, TrainingEquipmentSearchObject search)
    {
        if (search.TrainingId.HasValue)
        {
            query = query.Where(x => x.TrainingId == search.TrainingId.Value);
        }

        return query;
    }

    protected override Task ValidateInsert(TrainingEquipmentInsertRequest request, CancellationToken cancellationToken)
        => EnsureTrainingExistsAsync(request.TrainingId, cancellationToken);

    protected override Task ValidateUpdate(int id, TrainingEquipmentUpdateRequest request, TrainingEquipmentEntity entity, CancellationToken cancellationToken)
        => EnsureTrainingExistsAsync(request.TrainingId, cancellationToken);

    private async Task EnsureTrainingExistsAsync(int trainingId, CancellationToken cancellationToken)
    {
        var trainingExists = await _dbContext.Trainings
            .AnyAsync(t => t.Id == trainingId, cancellationToken);

        if (!trainingExists)
        {
            throw new NotFoundException($"Training with id {trainingId} was not found.");
        }
    }
}
