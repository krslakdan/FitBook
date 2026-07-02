using FitBook.Model.Requests.UserAccounts;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserAccountAdminPasswordResetRequestValidator : AbstractValidator<UserAccountAdminPasswordResetRequest>
{
    public UserAccountAdminPasswordResetRequestValidator()
    {
        RuleFor(x => x.NewPassword).NotEmpty().MinimumLength(8).MaximumLength(128);
    }
}
