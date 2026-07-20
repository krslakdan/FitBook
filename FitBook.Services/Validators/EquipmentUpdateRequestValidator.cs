using FitBook.Model.Requests.Equipment;
using FluentValidation;

namespace FitBook.Services.Validators;

public class EquipmentUpdateRequestValidator : AbstractValidator<EquipmentUpdateRequest>
{
    public EquipmentUpdateRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv opreme je obavezan.")
            .MaximumLength(120).WithMessage("Naziv opreme ne smije biti duži od 120 karaktera.");
    }
}
