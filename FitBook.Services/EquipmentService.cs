using FitBook.Model.Exceptions;
using FitBook.Model.Requests.Equipment;
using FitBook.Model.Responses.Equipment;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using EquipmentEntity = FitBook.Services.Database.Entities.Equipment;

namespace FitBook.Services;

public class EquipmentService
    : BaseCRUDService<EquipmentEntity, EquipmentResponse, EquipmentSearchObject, EquipmentInsertRequest, EquipmentUpdateRequest>,
      IEquipmentService
{
    public EquipmentService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<EquipmentInsertRequest> insertValidator,
        IValidator<EquipmentUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
    }

    protected override IQueryable<EquipmentEntity> ApplyFilter(IQueryable<EquipmentEntity> query, EquipmentSearchObject search)
    {
        if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        return query;
    }

    protected override IQueryable<EquipmentEntity> ApplySearch(IQueryable<EquipmentEntity> query, EquipmentSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Search))
        {
            var term = search.Search.Trim().ToLowerInvariant();
            query = query.Where(x => x.Name.ToLower().Contains(term));
        }

        return query;
    }

    protected override async Task ValidateInsert(EquipmentInsertRequest request, CancellationToken cancellationToken)
    {
        await EnsureNameIsUniqueAsync(request.Name, excludeId: null, cancellationToken);
    }

    protected override async Task ValidateUpdate(int id, EquipmentUpdateRequest request, EquipmentEntity entity, CancellationToken cancellationToken)
    {
        await EnsureNameIsUniqueAsync(request.Name, excludeId: id, cancellationToken);
    }

    protected override async Task ValidateDelete(int id, EquipmentEntity entity, CancellationToken cancellationToken)
    {
        var isUsed = await _dbContext.TrainingEquipment
            .AnyAsync(x => x.EquipmentId == id, cancellationToken);

        if (isUsed)
        {
            throw new BusinessException($"Oprema '{entity.Name}' ne može biti obrisana jer postoje treninzi koji je koriste. Označite je kao neaktivnu umjesto brisanja.");
        }
    }

    private async Task EnsureNameIsUniqueAsync(string name, int? excludeId, CancellationToken cancellationToken)
    {
        var normalized = name.Trim().ToLowerInvariant();
        var duplicateExists = await _dbContext.Equipment
            .AnyAsync(x => x.Name.ToLower() == normalized && (excludeId == null || x.Id != excludeId.Value), cancellationToken);

        if (duplicateExists)
        {
            throw new BusinessException($"Oprema sa nazivom '{name.Trim()}' već postoji.");
        }
    }
}
