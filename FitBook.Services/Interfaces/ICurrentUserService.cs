namespace FitBook.Services.Interfaces
{
    public interface ICurrentUserService
    {
        bool IsAuthenticated();
        int? GetUserId();
        int GetRequiredUserId();
        string? GetUsername();
        string? GetEmail();
        bool IsActive();
        string? GetRole();
        bool IsInRole(string role);
        bool IsAdmin();
    }
}
