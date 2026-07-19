using FitBook.Model.Requests.Auth;
using FluentValidation;

namespace FitBook.Services.Validators;

public class ForgotPasswordRequestValidator : AbstractValidator<ForgotPasswordRequest>
{
    public ForgotPasswordRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail adresa je obavezna.")
            .EmailAddress().WithMessage("Unesite validnu e-mail adresu u formatu: ime@domena.com.")
            .MaximumLength(256).WithMessage("E-mail adresa ne smije biti duža od 256 karaktera.");
    }
}
