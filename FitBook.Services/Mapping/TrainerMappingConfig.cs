using FitBook.Model.Requests.Trainers;
using FitBook.Model.Responses.Trainers;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class TrainerMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<Trainer, TrainerResponse>()
            .Map(dest => dest.SpecializationName,
                src => src.Specialization != null ? src.Specialization.Name : string.Empty);

#pragma warning disable CS8603
        config.NewConfig<TrainerInsertRequest, Trainer>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Specialization)
            .Ignore(dest => dest.UserAccount)
            .Ignore(dest => dest.TrainingTerms)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<TrainerUpdateRequest, Trainer>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Specialization)
            .Ignore(dest => dest.UserAccountId)
            .Ignore(dest => dest.UserAccount)
            .Ignore(dest => dest.TrainingTerms)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
