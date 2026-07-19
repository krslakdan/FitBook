using FitBook.Model.Requests.Auth;
using FluentValidation;

namespace FitBook.Services.Validators;

public class ResetPasswordRequestValidator : AbstractValidator<ResetPasswordRequest>
{
    public ResetPasswordRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("E-mail adresa je obavezna.")
            .EmailAddress().WithMessage("Unesite validnu e-mail adresu u formatu: ime@domena.com.")
            .MaximumLength(256).WithMessage("E-mail adresa ne smije biti duža od 256 karaktera.");

        RuleFor(x => x.Code)
            .NotEmpty().WithMessage("Kod za reset lozinke je obavezan.")
            .Matches("^[0-9]{6}$").WithMessage("Kod za reset lozinke mora sadržavati tačno 6 cifara.");

        RuleFor(x => x.NewPassword)
            .NotEmpty().WithMessage("Nova lozinka je obavezna.")
            .MinimumLength(8).WithMessage("Nova lozinka mora imati najmanje 8 karaktera.")
            .MaximumLength(128).WithMessage("Nova lozinka ne smije biti duža od 128 karaktera.");
    }
}
