using FitBook.Model.Requests.Specializations;
using FitBook.Model.Responses.Specializations;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class SpecializationMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<Specialization, SpecializationResponse>();

#pragma warning disable CS8603
        config.NewConfig<SpecializationInsertRequest, Specialization>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Trainers)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<SpecializationUpdateRequest, Specialization>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Trainers)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
