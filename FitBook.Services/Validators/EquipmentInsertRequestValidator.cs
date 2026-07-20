using FitBook.Model.Requests.Equipment;
using FluentValidation;

namespace FitBook.Services.Validators;

public class EquipmentInsertRequestValidator : AbstractValidator<EquipmentInsertRequest>
{
    public EquipmentInsertRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv opreme je obavezan.")
            .MaximumLength(120).WithMessage("Naziv opreme ne smije biti duži od 120 karaktera.");
    }
}
