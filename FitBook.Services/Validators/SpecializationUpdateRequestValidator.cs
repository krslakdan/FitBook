using FitBook.Model.Requests.Specializations;
using FluentValidation;

namespace FitBook.Services.Validators;

public class SpecializationUpdateRequestValidator : AbstractValidator<SpecializationUpdateRequest>
{
    public SpecializationUpdateRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv specijalizacije je obavezan.")
            .MaximumLength(150).WithMessage("Naziv specijalizacije ne smije biti duži od 150 karaktera.");
    }
}
