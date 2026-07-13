using FitBook.Model.Requests.Halls;
using FluentValidation;

namespace FitBook.Services.Validators;

public class HallInsertRequestValidator : AbstractValidator<HallInsertRequest>
{
    public HallInsertRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv sale je obavezan.")
            .MaximumLength(100).WithMessage("Naziv sale ne smije biti duži od 100 karaktera.");

        RuleFor(x => x.Capacity)
            .GreaterThan(0).WithMessage("Kapacitet sale mora biti pozitivan broj.");

        RuleFor(x => x.LocationDescription)
            .MaximumLength(250).WithMessage("Opis lokacije ne smije biti duži od 250 karaktera.")
            .When(x => x.LocationDescription is not null);
    }
}
