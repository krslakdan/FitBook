using System.ComponentModel.DataAnnotations;

namespace FitBook.Model.Requests.UserAccounts;

public class UserAccountChangeOwnPasswordRequest
{
    public string CurrentPassword { get; set; } = string.Empty;

    public string NewPassword { get; set; } = string.Empty;
}
