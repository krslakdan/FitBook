using FitBook.Model.Requests.TrainingEquipment;
using FitBook.Model.Responses.TrainingEquipment;
using Mapster;
using TrainingEquipmentEntity = FitBook.Services.Database.Entities.TrainingEquipment;

namespace FitBook.Services.Mapping;

public class TrainingEquipmentMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<TrainingEquipmentEntity, TrainingEquipmentResponse>()
            .Map(dest => dest.EquipmentName,
                src => src.Equipment != null ? src.Equipment.Name : string.Empty);

#pragma warning disable CS8603
        config.NewConfig<TrainingEquipmentInsertRequest, TrainingEquipmentEntity>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Training)
            .Ignore(dest => dest.Equipment)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<TrainingEquipmentUpdateRequest, TrainingEquipmentEntity>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Training)
            .Ignore(dest => dest.Equipment)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
