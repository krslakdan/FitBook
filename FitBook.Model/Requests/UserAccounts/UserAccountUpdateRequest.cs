namespace FitBook.Model.Requests.UserAccounts;

public class UserAccountUpdateRequest
{
    public string? FirstName { get; set; }

    public string? LastName { get; set; }
    public string? Email { get; set; }

    public string? PhoneNumber { get; set; }

    public string? Username { get; set; }

    public string? Role { get; set; }

    public string? ProfileImageUrl { get; set; }

    public bool? IsActive { get; set; }
}
