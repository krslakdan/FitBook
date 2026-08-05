using FitBook.Model.Constants;
using FitBook.Model.Requests.MembershipPackages;
using FluentValidation;

namespace FitBook.Services.Validators;

public class MembershipPackageInsertRequestValidator : AbstractValidator<MembershipPackageInsertRequest>
{
    public MembershipPackageInsertRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .WithMessage("Naziv paketa je obavezan.")
            .MaximumLength(150)
            .WithMessage("Naziv paketa ne smije biti duži od 150 karaktera.");

        RuleFor(x => x.DurationDays)
            .InclusiveBetween(MembershipPackageConstants.MinDurationDays, MembershipPackageConstants.MaxDurationDays)
            .WithMessage($"Trajanje paketa mora biti između {MembershipPackageConstants.MinDurationDays} i {MembershipPackageConstants.MaxDurationDays} dana.");

        RuleFor(x => x.Price)
            .InclusiveBetween(PaymentConstants.MinChargeAmount, PaymentConstants.MaxChargeAmount)
            .WithMessage($"Cijena paketa mora biti između {PaymentConstants.MinChargeAmount:0.00} i {PaymentConstants.MaxChargeAmount:0.00} {PaymentConstants.Currency.ToUpperInvariant()}.");

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
