using FitBook.Model.Requests.TrainingCategories;
using FluentValidation;

namespace FitBook.Services.Validators;

public class TrainingCategoryInsertRequestValidator : AbstractValidator<TrainingCategoryInsertRequest>
{
    public TrainingCategoryInsertRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Naziv kategorije je obavezan.")
            .MaximumLength(120).WithMessage("Naziv kategorije ne smije biti duži od 120 karaktera.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Opis kategorije ne smije biti duži od 500 karaktera.")
            .When(x => x.Description is not null);
    }
}
