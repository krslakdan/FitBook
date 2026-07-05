using FitBook.Model.Enums;
using FitBook.Model.Exceptions;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace FitBook.Services;

public class ReservationService : IReservationService
{
    private static readonly ReservationStatus[] ActiveStatuses =
    [
        ReservationStatus.Pending,
        ReservationStatus.Confirmed
    ];

    private readonly FitBookDbContext _context;

    public ReservationService(FitBookDbContext context)
    {
        _context = context;
    }

    public async Task EnsureNoActiveReservationForTermAsync(
        int userAccountId,
        int trainingTermId,
        CancellationToken cancellationToken = default)
    {
        var hasActiveReservation = await _context.Reservations
            .AnyAsync(
                r => r.UserAccountId == userAccountId
                     && r.TrainingTermId == trainingTermId
                     && ActiveStatuses.Contains(r.Status),
                cancellationToken);

        if (hasActiveReservation)
        {
            throw new BusinessException("You already have an active reservation for this training term.");
        }
    }
}
