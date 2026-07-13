using FitBook.Model.Requests.MembershipPackages;
using FitBook.Model.Responses.MembershipPackages;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class MembershipPackageMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<MembershipPackage, MembershipPackageResponse>();

#pragma warning disable CS8603
        config.NewConfig<MembershipPackageInsertRequest, MembershipPackage>()
            .Ignore(destination => destination.Id)
            .Ignore(destination => destination.IsDeleted)
            .Ignore(destination => destination.UserMemberships)
            .Ignore(destination => destination.CreatedAtUtc)
            .Ignore(destination => destination.UpdatedAtUtc);

        config.NewConfig<MembershipPackageUpdateRequest, MembershipPackage>()
            .IgnoreNullValues(true)
            .Ignore(destination => destination.Id)
            .Ignore(destination => destination.IsDeleted)
            .Ignore(destination => destination.UserMemberships)
            .Ignore(destination => destination.CreatedAtUtc)
            .Ignore(destination => destination.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
