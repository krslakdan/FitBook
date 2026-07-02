using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses.UserAccounts;
using FitBook.Model.SearchObjects;
using FitBook.Services.Interfaces;

namespace FitBook.Services;

public interface IUserAccountService
    : IBaseCRUDService<UserAccountResponse, UserSearchObject, UserAccountInsertRequest, UserAccountUpdateRequest>
{
}
