using FitBook.Model.Constants;
using FitBook.Model.Requests.UserAccounts;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserAccountInsertRequestValidator : AbstractValidator<UserAccountInsertRequest>
{
    public UserAccountInsertRequestValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("Ime je obavezno.")
            .MinimumLength(2).WithMessage("Ime mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("Ime ne smije biti duže od 100 karaktera.");
        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Prezime je obavezno.")
            .MinimumLength(2).WithMessage("Prezime mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("Prezime ne smije biti duže od 100 karaktera.");
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email adresa je obavezna.")
            .Matches(ValidationPatterns.Email)
            .WithMessage("Email adresa mora biti u formatu: ime@domena.com.")
            .MaximumLength(200).WithMessage("Email adresa ne smije biti duža od 200 karaktera.");
        RuleFor(x => x.PhoneNumber)
            .NotEmpty().WithMessage("Broj telefona je obavezan.")
            .Matches(ValidationPatterns.Phone)
            .WithMessage("Broj telefona mora biti u formatu: +38761234567 ili 061234567 (6-20 cifara).")
            .MaximumLength(30).WithMessage("Broj telefona ne smije biti duži od 30 karaktera.");
        RuleFor(x => x.Username)
            .NotEmpty().WithMessage("Korisničko ime je obavezno.")
            .MinimumLength(3).WithMessage("Korisničko ime mora imati najmanje 3 karaktera.")
            .MaximumLength(100).WithMessage("Korisničko ime ne smije biti duže od 100 karaktera.");
        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Lozinka je obavezna.")
            .MinimumLength(8).WithMessage("Lozinka mora imati najmanje 8 karaktera.")
            .MaximumLength(128).WithMessage("Lozinka ne smije biti duža od 128 karaktera.");
        RuleFor(x => x.Role)
            .NotEmpty().WithMessage("Uloga je obavezna.")
            .Must(role => Roles.All.Contains(role))
            .WithMessage($"Uloga mora biti jedna od: {string.Join(", ", Roles.All)}.");
        RuleFor(x => x.ProfileImageUrl)
            .MaximumLength(500).WithMessage("URL profilne slike ne smije biti duži od 500 karaktera.");
    }
}
