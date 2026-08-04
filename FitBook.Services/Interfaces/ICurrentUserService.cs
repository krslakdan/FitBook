namespace FitBook.Services.Interfaces
{
    public interface ICurrentUserService
    {
        int GetRequiredUserId();
        bool IsInRole(string role);
        bool IsAdmin();
    }
}
