using FitBook.Model.Requests.TrainingEquipment;
using FluentValidation;

namespace FitBook.Services.Validators;

public class TrainingEquipmentUpdateRequestValidator : AbstractValidator<TrainingEquipmentUpdateRequest>
{
    public TrainingEquipmentUpdateRequestValidator()
    {
        RuleFor(x => x.EquipmentId)
            .GreaterThan(0).WithMessage("Oprema je obavezna.");

        RuleFor(x => x.Note)
            .MaximumLength(300).WithMessage("Napomena ne smije biti duža od 300 karaktera.")
            .When(x => x.Note is not null);

        RuleFor(x => x.TrainingId)
            .GreaterThan(0).WithMessage("TrainingId mora biti pozitivan broj.");
    }
}
