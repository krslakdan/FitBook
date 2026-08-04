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

        public int GetRequiredUserId()
        {
            var value = Principal?.FindFirst(ClaimNames.Id)?.Value;

            return int.TryParse(value, out var id)
                ? id
                : throw new InvalidOperationException(
                    "Current user id is not available. This method requires an authenticated request context.");
        }

        public bool IsInRole(string role) => Principal?.IsInRole(role) ?? false;

        public bool IsAdmin() => IsInRole(Roles.Admin);
    }
}
