using FitBook.Model.Requests.MembershipPackages;
using FluentValidation;

namespace FitBook.Services.Validators;

public class MembershipPackageUpdateRequestValidator : AbstractValidator<MembershipPackageUpdateRequest>
{
    public MembershipPackageUpdateRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .WithMessage("Naziv paketa je obavezan.")
            .MaximumLength(150)
            .WithMessage("Naziv paketa ne smije biti duži od 150 karaktera.");

        RuleFor(x => x.DurationDays)
            .GreaterThan(0)
            .WithMessage("Trajanje paketa mora biti pozitivan broj dana.");

        RuleFor(x => x.Price)
            .GreaterThan(0)
            .WithMessage("Cijena paketa mora biti veća od nule.");

        When(x => x.SavingsAmount.HasValue, () =>
        {
            RuleFor(x => x.SavingsAmount!.Value)
                .GreaterThanOrEqualTo(0)
                .WithMessage("Iznos uštedine ne može biti negativan.");
        });

        RuleFor(x => x.IncludedBenefits)
            .NotEmpty()
            .WithMessage("Opis benefita je obavezan.");
    }
}
