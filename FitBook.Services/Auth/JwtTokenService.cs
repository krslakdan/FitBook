using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using FitBook.Model.Constants;
using FitBook.Services.Configuration;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces.Auth;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace FitBook.Services.Auth;

public class JwtTokenService : IJwtTokenService
{
    private readonly JwtOptions _options;
    private readonly SigningCredentials _signingCredentials;

    public JwtTokenService(IOptions<JwtOptions> options)
    {
        _options = options.Value;

        if (string.IsNullOrWhiteSpace(_options.SecretKey))
        {
            throw new InvalidOperationException("JwtToken:SecretKey configuration value is required but was not provided.");
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.SecretKey));
        _signingCredentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
    }

    public string GenerateAccessToken(UserAccount user)
    {
        var claims = new List<Claim>
        {
            new Claim(ClaimNames.Id, user.Id.ToString()),
            new Claim(ClaimNames.Username, user.Username),
            new Claim(ClaimNames.Email, user.Email),
            new Claim(ClaimNames.FirstName, user.FirstName),
            new Claim(ClaimNames.LastName, user.LastName),
            new Claim(ClaimNames.Role, user.Role)
        };

        var token = new JwtSecurityToken(
            issuer: _options.Issuer,
            audience: _options.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_options.ExpirationMinutes),
            signingCredentials: _signingCredentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
