using FitBook.Model.Requests.Auth;
using FitBook.Model.Responses.Auth;

namespace FitBook.Services.Interfaces.Auth;

public interface IAuthService
{
    Task<UserLoginResponse> LoginAsync(UserLoginRequest request, CancellationToken cancellationToken = default);
    Task RegisterAsync(UserRegisterRequest request, CancellationToken cancellationToken = default);
    Task<RefreshTokenResponse> RefreshTokenAsync(RefreshTokenRequest request, CancellationToken cancellationToken = default);
    Task LogoutAsync(int userId, LogoutRequest request, CancellationToken cancellationToken = default);
}
