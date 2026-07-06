using FitBook.Model.Enums;
using FitBook.Model.Exceptions;
using FitBook.Model.Requests.Reservations;
using FitBook.Model.Responses.Reservations;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class ReservationService
    : BaseCRUDService<Reservation, ReservationResponse, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>,
      IReservationService
{
    private static readonly Dictionary<ReservationStatus, ReservationStatus[]> _allowedTransitions = new()
    {
        [ReservationStatus.Pending]   = [ReservationStatus.Confirmed, ReservationStatus.Cancelled],
        [ReservationStatus.Confirmed] = [ReservationStatus.Cancelled, ReservationStatus.Completed],
        [ReservationStatus.Cancelled] = [],
        [ReservationStatus.Completed] = [],
    };

    private static readonly ReservationStatus[] _activeStatuses =
    [
        ReservationStatus.Pending,
        ReservationStatus.Confirmed,
    ];

    private readonly ICurrentUserService _currentUserService;
    private readonly IValidator<ReservationCancelRequest> _cancelValidator;

    public ReservationService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        ICurrentUserService currentUserService,
        IValidator<ReservationInsertRequest> insertValidator,
        IValidator<ReservationUpdateRequest> updateValidator,
        IValidator<ReservationCancelRequest> cancelValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
        _currentUserService = currentUserService;
        _cancelValidator = cancelValidator;
    }

    protected override IQueryable<Reservation> ApplyFilter(IQueryable<Reservation> query, ReservationSearchObject search)
    {
        if (!_currentUserService.IsAdmin())
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(r => r.UserAccountId == currentUserId);
        }
        else if (search.UserAccountId.HasValue)
        {
            query = query.Where(r => r.UserAccountId == search.UserAccountId.Value);
        }

        if (search.TrainingTermId.HasValue)
        {
            query = query.Where(r => r.TrainingTermId == search.TrainingTermId.Value);
        }

        if (search.Status.HasValue)
        {
            query = query.Where(r => r.Status == search.Status.Value);
        }

        if (search.ReservedFromUtc.HasValue)
        {
            query = query.Where(r => r.ReservedAtUtc >= search.ReservedFromUtc.Value);
        }

        if (search.ReservedToUtc.HasValue)
        {
            query = query.Where(r => r.ReservedAtUtc <= search.ReservedToUtc.Value);
        }

        return query;
    }

    protected override async Task ValidateInsert(ReservationInsertRequest request, CancellationToken cancellationToken)
    {
        var currentUserId = _currentUserService.GetRequiredUserId();

        var term = await _dbContext.TrainingTerms
            .Include(t => t.Training)
            .FirstOrDefaultAsync(t => t.Id == request.TrainingTermId, cancellationToken);

        if (term is null)
        {
            throw new NotFoundException($"TrainingTerm with id {request.TrainingTermId} was not found.");
        }

        if (!term.IsActive)
        {
            throw new BusinessException("Ovaj trening termin nije aktivan.");
        }

        if (term.Status == TrainingTermStatus.Cancelled)
        {
            throw new BusinessException("Ovaj trening termin je otkazan.");
        }

        var activeCount = await _dbContext.Reservations
            .CountAsync(
                r => r.TrainingTermId == request.TrainingTermId
                     && _activeStatuses.Contains(r.Status),
                cancellationToken);

        if (activeCount >= term.MaxParticipants)
        {
            throw new BusinessException("Nema slobodnih mjesta za ovaj trening termin.");
        }

        await EnsureNoActiveReservationForTermAsync(currentUserId, request.TrainingTermId, cancellationToken);
    }

    protected override Task BeforeInsert(ReservationInsertRequest request, Reservation entity, CancellationToken cancellationToken)
    {
        entity.UserAccountId = _currentUserService.GetRequiredUserId();
        entity.Status = ReservationStatus.Pending;
        entity.ReservedAtUtc = DateTime.UtcNow;
        return Task.CompletedTask;
    }

    public override Task<ReservationResponse> UpdateAsync(int id, ReservationUpdateRequest request, CancellationToken cancellationToken = default)
    {
        throw new BusinessException("Rezervacije se ne mogu mijenjati putem generičkog Update endpointa. Koristite /confirm, /cancel ili /complete.");
    }

    public override Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        throw new BusinessException("Rezervacije se ne brišu. Status se mijenja kroz namjenske endpointe.");
    }

    public async Task<ReservationResponse> ConfirmAsync(int id, CancellationToken cancellationToken = default)
    {
        var reservation = await FindTrackedReservationAsync(id, cancellationToken);

        EnsureValidTransition(reservation.Status, ReservationStatus.Confirmed);

        var previousStatus = reservation.Status;
        reservation.Status = ReservationStatus.Confirmed;
        reservation.ConfirmedAtUtc = DateTime.UtcNow;
        reservation.UpdatedAtUtc = DateTime.UtcNow;
        reservation.LastStatusChangedByUserAccountId = _currentUserService.GetRequiredUserId();

        AddStatusAudit(reservation, previousStatus, ReservationStatus.Confirmed, reason: null);

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Reservation {ReservationId} confirmed by user {UserId}.",
            reservation.Id,
            _currentUserService.GetRequiredUserId());

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<ReservationResponse> CancelAsync(int id, ReservationCancelRequest request, CancellationToken cancellationToken = default)
    {
        await _cancelValidator.ValidateAndThrowAsync(request, cancellationToken);

        var reservation = await FindTrackedReservationAsync(id, cancellationToken);

        if (!_currentUserService.IsAdmin() && reservation.UserAccountId != _currentUserService.GetRequiredUserId())
        {
            throw new BusinessException("Nemate pravo otkazati ovu rezervaciju.");
        }

        EnsureValidTransition(reservation.Status, ReservationStatus.Cancelled);

        var previousStatus = reservation.Status;
        reservation.Status = ReservationStatus.Cancelled;
        reservation.CancelledAtUtc = DateTime.UtcNow;
        reservation.CancellationReason = request.Reason;
        reservation.UpdatedAtUtc = DateTime.UtcNow;
        reservation.LastStatusChangedByUserAccountId = _currentUserService.GetRequiredUserId();

        AddStatusAudit(reservation, previousStatus, ReservationStatus.Cancelled, reason: request.Reason);

        var termStartFormatted = reservation.TrainingTerm is not null
            ? reservation.TrainingTerm.StartTimeUtc.ToString("yyyy-MM-dd HH:mm") + " UTC"
            : $"termin #{reservation.TrainingTermId}";

        _dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = reservation.UserAccountId,
            NotificationType = NotificationType.ReservationCancelled,
            Title = "Vaša rezervacija je otkazana",
            Content = $"Vaša rezervacija za {termStartFormatted} je otkazana. Razlog: {request.Reason}",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow,
        });

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Reservation {ReservationId} cancelled by user {UserId}. Reason: {Reason}",
            reservation.Id,
            _currentUserService.GetRequiredUserId(),
            request.Reason);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<ReservationResponse> CompleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var reservation = await FindTrackedReservationAsync(id, cancellationToken);

        EnsureValidTransition(reservation.Status, ReservationStatus.Completed);

        if (reservation.TrainingTerm is not null && reservation.TrainingTerm.EndTimeUtc > DateTime.UtcNow)
        {
            throw new BusinessException("Trening termin još nije završio. Rezervacija se može kompletirati tek nakon završetka termina.");
        }

        var previousStatus = reservation.Status;
        reservation.Status = ReservationStatus.Completed;
        reservation.CompletedAtUtc = DateTime.UtcNow;
        reservation.UpdatedAtUtc = DateTime.UtcNow;
        reservation.LastStatusChangedByUserAccountId = _currentUserService.GetRequiredUserId();

        AddStatusAudit(reservation, previousStatus, ReservationStatus.Completed, reason: null);

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Reservation {ReservationId} completed by user {UserId}.",
            reservation.Id,
            _currentUserService.GetRequiredUserId());

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task EnsureNoActiveReservationForTermAsync(
        int userAccountId,
        int trainingTermId,
        CancellationToken cancellationToken = default)
    {
        var hasActiveReservation = await _dbContext.Reservations
            .AnyAsync(
                r => r.UserAccountId == userAccountId
                     && r.TrainingTermId == trainingTermId
                     && _activeStatuses.Contains(r.Status),
                cancellationToken);

        if (hasActiveReservation)
        {
            throw new BusinessException("Već imate aktivnu rezervaciju za ovaj trening termin.");
        }
    }

    private void EnsureValidTransition(ReservationStatus from, ReservationStatus to)
    {
        if (!_allowedTransitions.TryGetValue(from, out var allowed) || !allowed.Contains(to))
        {
            throw new BusinessException(
                $"Nije moguća tranzicija statusa rezervacije iz '{from}' u '{to}'.");
        }
    }

    private async Task<Reservation> FindTrackedReservationAsync(int id, CancellationToken cancellationToken)
    {
        var reservation = await _dbContext.Reservations
            .Include(r => r.TrainingTerm)
            .FirstOrDefaultAsync(r => r.Id == id, cancellationToken);

        if (reservation is null)
        {
            throw new NotFoundException($"Reservation with id {id} was not found.");
        }

        return reservation;
    }

    private void AddStatusAudit(
        Reservation reservation,
        ReservationStatus previousStatus,
        ReservationStatus newStatus,
        string? reason)
    {
        _dbContext.ReservationStatusAudits.Add(new ReservationStatusAudit
        {
            ReservationId = reservation.Id,
            PreviousStatus = previousStatus,
            NewStatus = newStatus,
            ChangedAtUtc = DateTime.UtcNow,
            Reason = reason,
            ChangedByUserAccountId = _currentUserService.GetRequiredUserId(),
            CreatedAtUtc = DateTime.UtcNow,
        });
    }
}
