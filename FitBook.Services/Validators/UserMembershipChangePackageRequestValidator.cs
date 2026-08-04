using FitBook.Model.Requests.UserMemberships;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserMembershipChangePackageRequestValidator : AbstractValidator<UserMembershipChangePackageRequest>
{
    public UserMembershipChangePackageRequestValidator()
    {
        RuleFor(x => x.MembershipPackageId)
            .GreaterThan(0)
            .WithMessage("Odaberite paket članarine na koji želite preći.");
    }
}
