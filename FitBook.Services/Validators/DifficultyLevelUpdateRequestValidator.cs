using FitBook.Model.Requests.DifficultyLevels;
using FluentValidation;

namespace FitBook.Services.Validators;

public class DifficultyLevelUpdateRequestValidator : AbstractValidator<DifficultyLevelUpdateRequest>
{
    public DifficultyLevelUpdateRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv nivoa težine je obavezan.")
            .MaximumLength(50).WithMessage("Naziv nivoa težine ne smije biti duži od 50 karaktera.");
    }
}
