using FitBook.Model.Requests.Equipment;
using FitBook.Model.Responses.Equipment;
using Mapster;
using EquipmentEntity = FitBook.Services.Database.Entities.Equipment;

namespace FitBook.Services.Mapping;

public class EquipmentMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<EquipmentEntity, EquipmentResponse>();

#pragma warning disable CS8603
        config.NewConfig<EquipmentInsertRequest, EquipmentEntity>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.TrainingEquipmentItems)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<EquipmentUpdateRequest, EquipmentEntity>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.TrainingEquipmentItems)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
