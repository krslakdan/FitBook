using FitBook.Model.Requests.TrainingCategories;
using FitBook.Model.Responses.TrainingCategories;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class TrainingCategoryMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<TrainingCategory, TrainingCategoryResponse>();

#pragma warning disable CS8603
        config.NewConfig<TrainingCategoryInsertRequest, TrainingCategory>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Trainings)
            .Ignore(dest => dest.RecommendationSignals)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<TrainingCategoryUpdateRequest, TrainingCategory>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Trainings)
            .Ignore(dest => dest.RecommendationSignals)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
