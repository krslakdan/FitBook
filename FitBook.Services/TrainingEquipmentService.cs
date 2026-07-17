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

    protected override async Task ValidateInsert(TrainingEquipmentInsertRequest request, CancellationToken cancellationToken)
    {
        await EnsureTrainingExistsAsync(request.TrainingId, cancellationToken);
        await EnsureEquipmentExistsAsync(request.EquipmentId, cancellationToken);
        await EnsurePairIsUniqueAsync(request.TrainingId, request.EquipmentId, excludeId: null, cancellationToken);
    }

    protected override async Task ValidateUpdate(int id, TrainingEquipmentUpdateRequest request, TrainingEquipmentEntity entity, CancellationToken cancellationToken)
    {
        await EnsureTrainingExistsAsync(request.TrainingId, cancellationToken);
        await EnsureEquipmentExistsAsync(request.EquipmentId, cancellationToken);
        await EnsurePairIsUniqueAsync(request.TrainingId, request.EquipmentId, excludeId: id, cancellationToken);
    }

    private async Task EnsureTrainingExistsAsync(int trainingId, CancellationToken cancellationToken)
    {
        var trainingExists = await _dbContext.Trainings
            .AnyAsync(t => t.Id == trainingId, cancellationToken);

        if (!trainingExists)
        {
            throw new NotFoundException($"Trening sa ID {trainingId} nije pronađen.");
        }
    }

    private async Task EnsureEquipmentExistsAsync(int equipmentId, CancellationToken cancellationToken)
    {
        var equipmentExists = await _dbContext.Equipment
            .AnyAsync(e => e.Id == equipmentId, cancellationToken);

        if (!equipmentExists)
        {
            throw new NotFoundException($"Oprema sa ID {equipmentId} nije pronađena.");
        }
    }

    private async Task EnsurePairIsUniqueAsync(int trainingId, int equipmentId, int? excludeId, CancellationToken cancellationToken)
    {
        var duplicateExists = await _dbContext.TrainingEquipment
            .AnyAsync(x => x.TrainingId == trainingId
                && x.EquipmentId == equipmentId
                && (excludeId == null || x.Id != excludeId.Value), cancellationToken);

        if (duplicateExists)
        {
            throw new BusinessException("Odabrana oprema je već dodijeljena ovom treningu.");
        }
    }
}
