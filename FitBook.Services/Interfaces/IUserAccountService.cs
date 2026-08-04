using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Responses.UserAccounts;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database.Entities;

namespace FitBook.Services.Interfaces;

public interface IUserAccountService
    : IBaseCRUDService<UserAccountResponse, UserSearchObject, UserAccountInsertRequest, UserAccountUpdateRequest>
{
    Task<UserAccount> CreateUserAsync(UserAccountInsertRequest request, CancellationToken cancellationToken = default);
    Task ChangeOwnPasswordAsync(int userId, UserAccountChangeOwnPasswordRequest request, CancellationToken cancellationToken = default);
    Task AdminResetPasswordAsync(int userId, UserAccountAdminPasswordResetRequest request, CancellationToken cancellationToken = default);
}
