using FitBook.Model.Requests.MembershipPackages;
using FitBook.Model.Responses.MembershipPackages;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IMembershipPackageService
    : IBaseCRUDService<MembershipPackageResponse, MembershipPackageSearchObject, MembershipPackageInsertRequest, MembershipPackageUpdateRequest>
{
}
