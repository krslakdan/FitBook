using FitBook.Services.Database.Entities;

namespace FitBook.Services.Interfaces.Auth;

public interface IJwtTokenService
{
    string GenerateAccessToken(UserAccount user);
}
