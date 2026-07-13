using FitBook.Model.Requests.TrainingTerms;
using FitBook.Model.Responses.TrainingTerms;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class TrainingTermMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<TrainingTerm, TrainingTermResponse>()
            .Map(dest => dest.TrainingName,
                src => src.Training != null ? src.Training.Name : string.Empty)
            .Map(dest => dest.TrainerFirstName,
                src => src.Trainer != null ? src.Trainer.FirstName : string.Empty)
            .Map(dest => dest.TrainerLastName,
                src => src.Trainer != null ? src.Trainer.LastName : string.Empty)
            .Map(dest => dest.HallName,
                src => src.Hall != null ? src.Hall.Name : string.Empty);

#pragma warning disable CS8603
        config.NewConfig<TrainingTermInsertRequest, TrainingTerm>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Status)
            .Ignore(dest => dest.Training)
            .Ignore(dest => dest.Trainer)
            .Ignore(dest => dest.Hall)
            .Ignore(dest => dest.Reservations)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<TrainingTermUpdateRequest, TrainingTerm>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.Status)
            .Ignore(dest => dest.TrainingId)
            .Ignore(dest => dest.Training)
            .Ignore(dest => dest.Trainer)
            .Ignore(dest => dest.Hall)
            .Ignore(dest => dest.Reservations)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
