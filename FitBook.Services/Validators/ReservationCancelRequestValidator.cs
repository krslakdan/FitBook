using FitBook.Model.Requests.Reservations;
using FluentValidation;

namespace FitBook.Services.Validators;

public class ReservationCancelRequestValidator : AbstractValidator<ReservationCancelRequest>
{
    public ReservationCancelRequestValidator()
    {
        RuleFor(x => x.Reason)
            .NotEmpty()
            .WithMessage("Razlog otkazivanja je obavezan.")
            .MaximumLength(500)
            .WithMessage("Razlog otkazivanja ne smije biti duži od 500 karaktera.");
    }
}
