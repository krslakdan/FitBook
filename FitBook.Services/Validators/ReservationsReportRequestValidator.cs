using FitBook.Model.Requests.Reports;
using FluentValidation;

namespace FitBook.Services.Validators;

public class ReservationsReportRequestValidator : AbstractValidator<ReservationsReportRequest>
{
    private const int MaxRangeDays = 730;

    public ReservationsReportRequestValidator()
    {
        RuleFor(x => x.FromUtc)
            .NotEmpty().WithMessage("Početak perioda je obavezan.");

        RuleFor(x => x.ToUtc)
            .NotEmpty().WithMessage("Kraj perioda je obavezan.")
            .Must((req, toUtc) => toUtc > req.FromUtc)
            .WithMessage("Kraj perioda mora biti nakon početka perioda.")
            .Must((req, toUtc) => (toUtc - req.FromUtc).TotalDays <= MaxRangeDays)
            .WithMessage($"Period izvještaja ne može biti duži od {MaxRangeDays} dana.");
    }
}
