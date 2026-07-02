using FitBook.Model.Constants;
using FitBook.Model.Requests.UserAccounts;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserAccountUpdateRequestValidator : AbstractValidator<UserAccountUpdateRequest>
{
    private const string PhonePattern = @"^(?=(?:.*\d){6,})\+?[0-9\s\-()]{6,20}$";

    public UserAccountUpdateRequestValidator()
    {
        RuleFor(x => x.FirstName).MinimumLength(2).MaximumLength(100).When(x => x.FirstName is not null);
        RuleFor(x => x.LastName).MinimumLength(2).MaximumLength(100).When(x => x.LastName is not null);
        RuleFor(x => x.Email).EmailAddress().MaximumLength(200).When(x => x.Email is not null);
        RuleFor(x => x.PhoneNumber)
            .Matches(PhonePattern)
            .WithMessage("Broj telefona nije u ispravnom formatu.")
            .MaximumLength(30)
            .When(x => x.PhoneNumber is not null);
        RuleFor(x => x.Username).MinimumLength(3).MaximumLength(100).When(x => x.Username is not null);
        RuleFor(x => x.Role)
            .Must(role => Roles.All.Contains(role))
            .WithMessage($"Role mora biti jedna od: {string.Join(", ", Roles.All)}.")
            .MaximumLength(50)
            .When(x => x.Role is not null);
        RuleFor(x => x.ProfileImageUrl).MaximumLength(500).When(x => x.ProfileImageUrl is not null);
    }
}
