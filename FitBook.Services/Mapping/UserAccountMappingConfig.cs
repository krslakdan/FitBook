using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses.UserAccounts;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class UserAccountMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<UserAccount, UserAccountResponse>();

        config.NewConfig<UserAccountInsertRequest, UserAccount>()
            .Ignore(destination => destination.Id)
            .Ignore(destination => destination.PasswordHash)
            .Ignore(destination => destination.Reservations)
            .Ignore(destination => destination.ReservationStatusChanged)
            .Ignore(destination => destination.ReservationStatusAudits)
            .Ignore(destination => destination.Notifications)
            .Ignore(destination => destination.Memberships)
            .Ignore(destination => destination.Payments)
            .Ignore(destination => destination.RecommendationSignals);

        config.NewConfig<UserAccountUpdateRequest, UserAccount>()
            .IgnoreNullValues(true)
            .Ignore(destination => destination.Id)
            .Ignore(destination => destination.PasswordHash)
            .Ignore(destination => destination.CreatedAtUtc)
            .Ignore(destination => destination.IsDeleted)
            .Ignore(destination => destination.Reservations)
            .Ignore(destination => destination.ReservationStatusChanged)
            .Ignore(destination => destination.ReservationStatusAudits)
            .Ignore(destination => destination.Notifications)
            .Ignore(destination => destination.Memberships)
            .Ignore(destination => destination.Payments)
            .Ignore(destination => destination.RecommendationSignals);
    }
}
