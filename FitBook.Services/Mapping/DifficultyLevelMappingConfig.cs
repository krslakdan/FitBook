using FitBook.Model.Requests.DifficultyLevels;
using FitBook.Model.Responses.DifficultyLevels;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class DifficultyLevelMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<DifficultyLevel, DifficultyLevelResponse>();

#pragma warning disable CS8603
        config.NewConfig<DifficultyLevelInsertRequest, DifficultyLevel>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Trainings)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<DifficultyLevelUpdateRequest, DifficultyLevel>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Trainings)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
