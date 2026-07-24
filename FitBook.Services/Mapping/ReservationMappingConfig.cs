using FitBook.Model.Requests.Reservations;
using FitBook.Model.Responses.Reservations;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class ReservationMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<Reservation, ReservationResponse>()
            .Map(
                destination => destination.TrainingName,
                source => source.TrainingTerm != null && source.TrainingTerm.Training != null
                    ? source.TrainingTerm.Training.Name
                    : string.Empty)
            .Map(
                destination => destination.TrainerFirstName,
                source => source.TrainingTerm != null && source.TrainingTerm.Trainer != null
                    ? source.TrainingTerm.Trainer.FirstName
                    : string.Empty)
            .Map(
                destination => destination.TrainerLastName,
                source => source.TrainingTerm != null && source.TrainingTerm.Trainer != null
                    ? source.TrainingTerm.Trainer.LastName
                    : string.Empty)
            .Map(
                destination => destination.HallName,
                source => source.TrainingTerm != null && source.TrainingTerm.Hall != null
                    ? source.TrainingTerm.Hall.Name
                    : string.Empty)
            .Map(
                destination => destination.TrainingTermStartTimeUtc,
                source => source.TrainingTerm != null
                    ? source.TrainingTerm.StartTimeUtc
                    : default(DateTime))
            .Map(
                destination => destination.TrainingTermEndTimeUtc,
                source => source.TrainingTerm != null
                    ? source.TrainingTerm.EndTimeUtc
                    : default(DateTime))
            .Map(
                destination => destination.UserFirstName,
                source => source.UserAccount != null 
                ? source.UserAccount.FirstName : string.Empty)
            .Map(
                destination => destination.UserLastName,
                source => source.UserAccount != null 
                ? source.UserAccount.LastName : string.Empty)
            .Map(
                destination => destination.UserEmail,
                source => source.UserAccount != null 
                ? source.UserAccount.Email : string.Empty);

#pragma warning disable CS8603
        config.NewConfig<ReservationInsertRequest, Reservation>()
            .Ignore(destination => destination.Id)
            .Ignore(destination => destination.Status)
            .Ignore(destination => destination.ReservedAtUtc)
            .Ignore(destination => destination.ConfirmedAtUtc)
            .Ignore(destination => destination.CancelledAtUtc)
            .Ignore(destination => destination.CompletedAtUtc)
            .Ignore(destination => destination.CancellationReason)
            .Ignore(destination => destination.UserAccountId)
            .Ignore(destination => destination.UserAccount)
            .Ignore(destination => destination.LastStatusChangedByUserAccountId)
            .Ignore(destination => destination.LastStatusChangedByUserAccount)
            .Ignore(destination => destination.TrainingTerm)
            .Ignore(destination => destination.StatusAudits)
            .Ignore(destination => destination.RecommendationSignals)
            .Ignore(destination => destination.CreatedAtUtc)
            .Ignore(destination => destination.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
