using FitBook.Model.Requests.Halls;
using FitBook.Model.Responses.Halls;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class HallMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<Hall, HallResponse>();

#pragma warning disable CS8603
        config.NewConfig<HallInsertRequest, Hall>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.TrainingTerms)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<HallUpdateRequest, Hall>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.TrainingTerms)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
