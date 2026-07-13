using FitBook.Model.Requests.UserMemberships;
using FluentValidation;

namespace FitBook.Services.Validators;

public class UserMembershipCancelRequestValidator : AbstractValidator<UserMembershipCancelRequest>
{
    public UserMembershipCancelRequestValidator()
    {
        RuleFor(x => x.Reason)
            .NotEmpty()
            .WithMessage("Razlog otkazivanja je obavezan.")
            .MaximumLength(500)
            .WithMessage("Razlog otkazivanja ne smije biti duži od 500 karaktera.");
    }
}
