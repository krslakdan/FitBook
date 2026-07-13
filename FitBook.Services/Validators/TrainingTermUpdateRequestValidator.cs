using FitBook.Model.Requests.TrainingTerms;
using FluentValidation;

namespace FitBook.Services.Validators;

public class TrainingTermUpdateRequestValidator : AbstractValidator<TrainingTermUpdateRequest>
{
    public TrainingTermUpdateRequestValidator()
    {
        RuleFor(x => x.StartTimeUtc)
            .NotEmpty().WithMessage("Vrijeme početka termina je obavezno.");

        RuleFor(x => x.EndTimeUtc)
            .NotEmpty().WithMessage("Vrijeme završetka termina je obavezno.")
            .Must((req, endTime) => endTime > req.StartTimeUtc)
            .WithMessage("Vrijeme završetka mora biti nakon vremena početka.");

        RuleFor(x => x.MaxParticipants)
            .GreaterThan(0).WithMessage("Maksimalni broj učesnika mora biti pozitivan broj.");

        RuleFor(x => x.TrainerId)
            .GreaterThan(0).WithMessage("TrainerId mora biti pozitivan broj.");

        RuleFor(x => x.HallId)
            .GreaterThan(0).WithMessage("HallId mora biti pozitivan broj.");
    }
}
