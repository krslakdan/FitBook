using FitBook.Model.Requests.Reports;
using FluentValidation;

namespace FitBook.Services.Validators;

public class ReservationsReportRequestValidator : AbstractValidator<ReservationsReportRequest>
{
    private const int MaxRangeDays = 730;

    public ReservationsReportRequestValidator()
    {
        RuleFor(x => x.FromDate)
            .NotEqual(default(DateOnly)).WithMessage("Početni datum termina je obavezan.");

        RuleFor(x => x.ToDate)
            .NotEqual(default(DateOnly)).WithMessage("Krajnji datum termina je obavezan.")
            .Must((req, toDate) => toDate >= req.FromDate)
            .WithMessage("Krajnji datum termina ne može biti prije početnog datuma.")
            .Must((req, toDate) => toDate.DayNumber - req.FromDate.DayNumber <= MaxRangeDays)
            .WithMessage($"Period izvještaja ne može biti duži od {MaxRangeDays} dana.");
    }
}
