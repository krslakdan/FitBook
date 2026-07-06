using FitBook.Model.Requests.Reservations;
using FluentValidation;

namespace FitBook.Services.Validators;

public class ReservationInsertRequestValidator : AbstractValidator<ReservationInsertRequest>
{
    public ReservationInsertRequestValidator()
    {
        RuleFor(x => x.TrainingTermId)
            .GreaterThan(0)
            .WithMessage("TrainingTermId mora biti pozitivan cijeli broj.");
    }
}
