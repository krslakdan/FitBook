using FitBook.Model.Requests.NewsItems;
using FluentValidation;

namespace FitBook.Services.Validators;

public class NewsItemInsertRequestValidator : AbstractValidator<NewsItemInsertRequest>
{
    public NewsItemInsertRequestValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Naslov vijesti je obavezan.")
            .MaximumLength(200).WithMessage("Naslov vijesti ne smije biti duži od 200 karaktera.");

        RuleFor(x => x.Content)
            .NotEmpty().WithMessage("Sadržaj vijesti je obavezan.");

        RuleFor(x => x.ImageUrl)
            .NotEmpty().WithMessage("Slika vijesti je obavezna.")
            .MaximumLength(500).WithMessage("URL slike ne smije biti duži od 500 karaktera.");
    }
}
