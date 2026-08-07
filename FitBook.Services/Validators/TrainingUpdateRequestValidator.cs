using FitBook.Model.Requests.Trainings;
using FluentValidation;

namespace FitBook.Services.Validators;

public class TrainingUpdateRequestValidator : AbstractValidator<TrainingUpdateRequest>
{
    public TrainingUpdateRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv treninga je obavezan.")
            .MaximumLength(150).WithMessage("Naziv treninga ne smije biti duži od 150 karaktera.");

        RuleFor(x => x.Description)
            .NotEmpty().WithMessage("Opis treninga je obavezan.")
            .MaximumLength(2000).WithMessage("Opis treninga ne smije biti duži od 2000 karaktera.");

        RuleFor(x => x.DurationMinutes)
            .GreaterThan(0).WithMessage("Trajanje treninga mora biti pozitivan broj minuta.");

        RuleFor(x => x.MaxParticipants)
            .GreaterThan(0).WithMessage("Maksimalni broj učesnika mora biti pozitivan broj.");

        RuleFor(x => x.TrainingCategoryId)
            .GreaterThan(0).WithMessage("Kategorija treninga je obavezna.");

        RuleFor(x => x.DifficultyLevelId)
            .GreaterThan(0).WithMessage("Nivo težine je obavezan.");
    }
}
