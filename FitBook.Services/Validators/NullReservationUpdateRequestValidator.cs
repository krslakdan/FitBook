using FitBook.Model.Requests.Reservations;
using FluentValidation;

namespace FitBook.Services.Validators;

public class NullReservationUpdateRequestValidator : AbstractValidator<ReservationUpdateRequest>
{
    public NullReservationUpdateRequestValidator()
    {     
    }
}
