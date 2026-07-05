using FitBook.Model.Constants;
using FitBook.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace FitBook.Services
{
    public class CurrentUserService : ICurrentUserService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CurrentUserService(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        private ClaimsPrincipal? Principal => _httpContextAccessor.HttpContext?.User;

        public bool IsAuthenticated() => Principal?.Identity?.IsAuthenticated ?? false;

        public int? GetUserId()
        {
            var value = Principal?.FindFirst(ClaimNames.Id)?.Value;
            return int.TryParse(value, out var id) ? id : null;
        }

        public int GetRequiredUserId()
        {
            return GetUserId() ?? throw new InvalidOperationException(
                "Current user id is not available. This method requires an authenticated request context.");
        }

        public string? GetUsername() => Principal?.FindFirst(ClaimNames.Username)?.Value;

        public string? GetEmail() => Principal?.FindFirst(ClaimNames.Email)?.Value;

        public bool IsActive()
        {
            var value = Principal?.FindFirst(ClaimNames.IsActive)?.Value;
            return bool.TryParse(value, out var isActive) && isActive;
        }

        public string? GetRole() => Principal?.FindFirst(ClaimNames.Role)?.Value;

        public bool IsInRole(string role) => Principal?.IsInRole(role) ?? false;

        public bool IsAdmin() => IsInRole(Roles.Admin);
    }
}
