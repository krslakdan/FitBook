using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses.UserAccounts;
using FitBook.Model.SearchObjects;
using FitBook.Services;

namespace FitBook.WebAPI.Controllers;

public class UserAccountsController
    : BaseCRUDController<
        UserAccountResponse,
        UserSearchObject,
        UserAccountInsertRequest,
        UserAccountUpdateRequest,
        IUserAccountService>
{
    public UserAccountsController(IUserAccountService service)
        : base(service)
    {
    }
}
