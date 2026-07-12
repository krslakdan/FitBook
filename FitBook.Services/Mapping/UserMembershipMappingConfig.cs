using FitBook.Model.Enums;
using FitBook.Model.Requests.UserMemberships;
using FitBook.Model.Responses.Payments;
using FitBook.Model.Responses.UserMemberships;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class UserMembershipMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<UserMembership, UserMembershipResponse>()
            .Map(
                destination => destination.PackageName,
                source => source.MembershipPackage != null ? source.MembershipPackage.Name : string.Empty)
            .Map(
                destination => destination.PackagePrice,
                source => source.MembershipPackage != null ? source.MembershipPackage.Price : 0m)
            .Map(
                destination => destination.PackageDurationDays,
                source => source.MembershipPackage != null ? source.MembershipPackage.DurationDays : 0)
            .Map(
                destination => destination.UserFirstName,
                source => source.UserAccount != null ? source.UserAccount.FirstName : string.Empty)
            .Map(
                destination => destination.UserLastName,
                source => source.UserAccount != null ? source.UserAccount.LastName : string.Empty)
            .Map(
                destination => destination.UserEmail,
                source => source.UserAccount != null ? source.UserAccount.Email : string.Empty)
            .Map(
                destination => destination.IsPaid,
                source => source.Payments.Any(p => p.Status == PaymentStatus.Completed));

        config.NewConfig<MembershipPayment, MembershipPaymentResponse>();

#pragma warning disable CS8603
        config.NewConfig<UserMembershipInsertRequest, UserMembership>()
            .Ignore(destination => destination.Id)
            .Ignore(destination => destination.Status)
            .Ignore(destination => destination.IsActive)
            .Ignore(destination => destination.IsDeleted)
            .Ignore(destination => destination.StartDateUtc)
            .Ignore(destination => destination.EndDateUtc)
            .Ignore(destination => destination.NextPaymentDateUtc)
            .Ignore(destination => destination.UserAccountId)
            .Ignore(destination => destination.UserAccount)
            .Ignore(destination => destination.MembershipPackage)
            .Ignore(destination => destination.Payments)
            .Ignore(destination => destination.CreatedAtUtc)
            .Ignore(destination => destination.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
