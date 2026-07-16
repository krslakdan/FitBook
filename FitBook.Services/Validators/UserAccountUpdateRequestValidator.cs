using FitBook.Model.Constants;
using FitBook.Model.Requests.UserAccounts;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserAccountUpdateRequestValidator : AbstractValidator<UserAccountUpdateRequest>
{
    private const string PhonePattern = @"^(?=(?:.*\d){6,})\+?[0-9\s\-()]{6,20}$";

    public UserAccountUpdateRequestValidator()
    {
        RuleFor(x => x.FirstName)
            .MinimumLength(2).WithMessage("Ime mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("Ime ne smije biti duže od 100 karaktera.")
            .When(x => x.FirstName is not null);
        RuleFor(x => x.LastName)
            .MinimumLength(2).WithMessage("Prezime mora imati najmanje 2 karaktera.")
            .MaximumLength(100).WithMessage("Prezime ne smije biti duže od 100 karaktera.")
            .When(x => x.LastName is not null);
        RuleFor(x => x.Email)
            .EmailAddress().WithMessage("Email adresa nije u ispravnom formatu.")
            .MaximumLength(200).WithMessage("Email adresa ne smije biti duža od 200 karaktera.")
            .When(x => x.Email is not null);
        RuleFor(x => x.PhoneNumber)
            .Matches(PhonePattern)
            .WithMessage("Broj telefona nije u ispravnom formatu.")
            .MaximumLength(30).WithMessage("Broj telefona ne smije biti duži od 30 karaktera.")
            .When(x => x.PhoneNumber is not null);
        RuleFor(x => x.Username)
            .MinimumLength(3).WithMessage("Korisničko ime mora imati najmanje 3 karaktera.")
            .MaximumLength(100).WithMessage("Korisničko ime ne smije biti duže od 100 karaktera.")
            .When(x => x.Username is not null);
        RuleFor(x => x.Role)
            .Must(role => Roles.All.Contains(role))
            .WithMessage($"Role mora biti jedna od: {string.Join(", ", Roles.All)}.")
            .MaximumLength(50).WithMessage("Uloga ne smije biti duža od 50 karaktera.")
            .When(x => x.Role is not null);
        RuleFor(x => x.ProfileImageUrl)
            .MaximumLength(500).WithMessage("URL profilne slike ne smije biti duži od 500 karaktera.")
            .When(x => x.ProfileImageUrl is not null);
    }
}
