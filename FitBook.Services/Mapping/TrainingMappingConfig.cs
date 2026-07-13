using FitBook.Model.Requests.Trainings;
using FitBook.Model.Responses.Trainings;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class TrainingMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<Training, TrainingResponse>()
            .Map(dest => dest.TrainingCategoryName,
                src => src.TrainingCategory != null ? src.TrainingCategory.Name : string.Empty)
            .Map(dest => dest.DifficultyLevelName,
                src => src.DifficultyLevel != null ? src.DifficultyLevel.Name : string.Empty);

#pragma warning disable CS8603
        config.NewConfig<TrainingInsertRequest, Training>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.TrainingCategory)
            .Ignore(dest => dest.DifficultyLevel)
            .Ignore(dest => dest.EquipmentItems)
            .Ignore(dest => dest.TrainingTerms)
            .Ignore(dest => dest.RecommendationSignals)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<TrainingUpdateRequest, Training>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.TrainingCategory)
            .Ignore(dest => dest.DifficultyLevel)
            .Ignore(dest => dest.EquipmentItems)
            .Ignore(dest => dest.TrainingTerms)
            .Ignore(dest => dest.RecommendationSignals)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
