using FitBook.Model.Constants;
using FitBook.Model.Requests.UserAccounts;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserAccountInsertRequestValidator : AbstractValidator<UserAccountInsertRequest>
{
    private const string PhonePattern = @"^(?=(?:.*\d){6,})\+?[0-9\s\-()]{6,20}$";

    public UserAccountInsertRequestValidator()
    {
        RuleFor(x => x.FirstName).NotEmpty().MinimumLength(2).MaximumLength(100);
        RuleFor(x => x.LastName).NotEmpty().MinimumLength(2).MaximumLength(100);
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(200);
        RuleFor(x => x.PhoneNumber)
            .NotEmpty()
            .Matches(PhonePattern)
            .WithMessage("Broj telefona nije u ispravnom formatu.")
            .MaximumLength(30);
        RuleFor(x => x.Username).NotEmpty().MinimumLength(3).MaximumLength(100);
        RuleFor(x => x.Password).NotEmpty().MinimumLength(8).MaximumLength(128);
        RuleFor(x => x.Role)
            .NotEmpty()
            .Must(role => Roles.All.Contains(role))
            .WithMessage($"Role mora biti jedna od: {string.Join(", ", Roles.All)}.");
        RuleFor(x => x.ProfileImageUrl).MaximumLength(500);
    }
}
