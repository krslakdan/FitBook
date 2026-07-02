using FitBook.Model.Requests.UserAccounts;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserAccountUpdateRequestValidator : AbstractValidator<UserAccountUpdateRequest>
{
    public UserAccountUpdateRequestValidator()
    {
        RuleFor(x => x.FirstName).MinimumLength(2).MaximumLength(100).When(x => x.FirstName is not null);
        RuleFor(x => x.LastName).MinimumLength(2).MaximumLength(100).When(x => x.LastName is not null);
        RuleFor(x => x.Email).EmailAddress().MaximumLength(200).When(x => x.Email is not null);
        RuleFor(x => x.PhoneNumber).MaximumLength(30).When(x => x.PhoneNumber is not null);
        RuleFor(x => x.Username).MinimumLength(3).MaximumLength(100).When(x => x.Username is not null);
        RuleFor(x => x.Role).MaximumLength(50).When(x => x.Role is not null);
        RuleFor(x => x.ProfileImageUrl).MaximumLength(500).When(x => x.ProfileImageUrl is not null);
    }
}
