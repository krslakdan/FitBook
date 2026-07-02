using FitBook.Model.Requests.UserAccounts;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserAccountInsertRequestValidator : AbstractValidator<UserAccountInsertRequest>
{
    public UserAccountInsertRequestValidator()
    {
        RuleFor(x => x.FirstName).NotEmpty().MinimumLength(2).MaximumLength(100);
        RuleFor(x => x.LastName).NotEmpty().MinimumLength(2).MaximumLength(100);
        RuleFor(x => x.Email).NotEmpty().EmailAddress().MaximumLength(200);
        RuleFor(x => x.PhoneNumber).NotEmpty().MaximumLength(30);
        RuleFor(x => x.Username).NotEmpty().MinimumLength(3).MaximumLength(100);
        RuleFor(x => x.Password).NotEmpty().MinimumLength(8).MaximumLength(128);
        RuleFor(x => x.Role).NotEmpty().MaximumLength(50);
        RuleFor(x => x.ProfileImageUrl).MaximumLength(500);
    }
}
