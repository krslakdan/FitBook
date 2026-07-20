using FitBook.Model.Requests.Trainers;
using FluentValidation;

namespace FitBook.Services.Validators;

public class TrainerUpdateRequestValidator : AbstractValidator<TrainerUpdateRequest>
{
    public TrainerUpdateRequestValidator()
    {
        RuleFor(x => x.FirstName)
            .NotEmpty().WithMessage("Ime trenera je obavezno.")
            .MaximumLength(100).WithMessage("Ime trenera ne smije biti duže od 100 karaktera.");

        RuleFor(x => x.LastName)
            .NotEmpty().WithMessage("Prezime trenera je obavezno.")
            .MaximumLength(100).WithMessage("Prezime trenera ne smije biti duže od 100 karaktera.");

        RuleFor(x => x.SpecializationId)
            .GreaterThan(0).WithMessage("Specijalizacija trenera je obavezna.");

        RuleFor(x => x.Biography)
            .MaximumLength(2000).WithMessage("Biografija ne smije biti duža od 2000 karaktera.")
            .When(x => x.Biography is not null);

        RuleFor(x => x.ImageUrl)
            .MaximumLength(500).WithMessage("URL slike ne smije biti duži od 500 karaktera.")
            .When(x => x.ImageUrl is not null);
    }
}
