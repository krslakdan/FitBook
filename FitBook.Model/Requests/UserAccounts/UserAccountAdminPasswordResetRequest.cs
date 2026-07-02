using System.ComponentModel.DataAnnotations;

namespace FitBook.Model.Requests.UserAccounts;

public class UserAccountAdminPasswordResetRequest
{
    public string NewPassword { get; set; } = string.Empty;
}
