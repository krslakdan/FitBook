using FitBook.Model.Requests.UserMemberships;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserMembershipInsertRequestValidator : AbstractValidator<UserMembershipInsertRequest>
{
    public UserMembershipInsertRequestValidator()
    {
        RuleFor(x => x.MembershipPackageId)
            .GreaterThan(0)
            .WithMessage("MembershipPackageId mora biti pozitivan cijeli broj.");
    }
}
