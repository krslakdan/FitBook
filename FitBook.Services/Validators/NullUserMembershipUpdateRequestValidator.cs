using FitBook.Model.Requests.UserMemberships;
using FluentValidation;

namespace FitBook.Services.Validators;

public class NullUserMembershipUpdateRequestValidator : AbstractValidator<UserMembershipUpdateRequest>
{
    public NullUserMembershipUpdateRequestValidator()
    {
    }
}
