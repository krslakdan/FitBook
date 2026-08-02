using FitBook.Model.Requests.UserAccounts;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserAccountChangeOwnPasswordRequestValidator : AbstractValidator<UserAccountChangeOwnPasswordRequest>
{
    public UserAccountChangeOwnPasswordRequestValidator()
    {
        RuleFor(x => x.CurrentPassword)
            .NotEmpty().WithMessage("Trenutna lozinka je obavezna.")
            .MaximumLength(128).WithMessage("Trenutna lozinka ne smije biti duža od 128 karaktera.");
        RuleFor(x => x.NewPassword)
            .NotEmpty().WithMessage("Nova lozinka je obavezna.")
            .MinimumLength(8).WithMessage("Nova lozinka mora imati najmanje 8 karaktera.")
            .MaximumLength(128).WithMessage("Nova lozinka ne smije biti duža od 128 karaktera.");
    }
}
