using FitBook.Model.Requests.TrainingEquipment;
using FluentValidation;

namespace FitBook.Services.Validators;

public class TrainingEquipmentUpdateRequestValidator : AbstractValidator<TrainingEquipmentUpdateRequest>
{
    public TrainingEquipmentUpdateRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv opreme je obavezan.")
            .MaximumLength(120).WithMessage("Naziv opreme ne smije biti duži od 120 karaktera.");

        RuleFor(x => x.Note)
            .MaximumLength(300).WithMessage("Napomena ne smije biti duža od 300 karaktera.")
            .When(x => x.Note is not null);

        RuleFor(x => x.TrainingId)
            .GreaterThan(0).WithMessage("TrainingId mora biti pozitivan broj.");
    }
}
