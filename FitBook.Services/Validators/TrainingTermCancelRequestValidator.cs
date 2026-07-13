using FitBook.Model.Requests.TrainingTerms;
using FluentValidation;

namespace FitBook.Services.Validators;

public class TrainingTermCancelRequestValidator : AbstractValidator<TrainingTermCancelRequest>
{
    public TrainingTermCancelRequestValidator()
    {
        RuleFor(x => x.Reason)
            .MaximumLength(500).WithMessage("Razlog otkazivanja ne smije biti duži od 500 karaktera.")
            .When(x => !string.IsNullOrWhiteSpace(x.Reason));
    }
}
