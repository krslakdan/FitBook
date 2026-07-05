using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using FitBook.Model.Constants;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces.Auth;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;

namespace FitBook.Services.Auth;

public class JwtTokenService : IJwtTokenService
{
    private readonly IConfiguration _configuration;

    public JwtTokenService(IConfiguration configuration)
    {
        _configuration = configuration;
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
            new Claim(ClaimNames.Role, user.Role),
            new Claim(ClaimNames.IsActive, user.IsActive.ToString())
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JwtToken:SecretKey"] ?? string.Empty));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var expirationMinutes = int.Parse(_configuration["JwtToken:ExpirationMinutes"] ?? "15");

        var token = new JwtSecurityToken(
            issuer: _configuration["JwtToken:Issuer"],
            audience: _configuration["JwtToken:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expirationMinutes),
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
