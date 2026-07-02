using FitBook.Model.Requests.UserAccounts;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserAccountChangeOwnPasswordRequestValidator : AbstractValidator<UserAccountChangeOwnPasswordRequest>
{
    public UserAccountChangeOwnPasswordRequestValidator()
    {
        RuleFor(x => x.CurrentPassword).NotEmpty().MinimumLength(8).MaximumLength(128);
        RuleFor(x => x.NewPassword).NotEmpty().MinimumLength(8).MaximumLength(128);
    }
}
