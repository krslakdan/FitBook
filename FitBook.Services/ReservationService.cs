using FitBook.Common.Services.Time;
using FitBook.Model.Constants;
using FitBook.Model.Enums;
using FitBook.Model.Exceptions;
using FitBook.Model.Messages;
using FitBook.Model.Requests.Reservations;
using FitBook.Model.Responses.Reservations;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FitBook.Services.Messaging;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Collections.Concurrent;

namespace FitBook.Services;

public class ReservationService
    : BaseCRUDService<Reservation, ReservationResponse, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>,
      IReservationService
{
    private static readonly Dictionary<ReservationStatus, ReservationStatus[]> _allowedTransitions = new()
    {
        [ReservationStatus.Pending] = [ReservationStatus.Confirmed, ReservationStatus.Cancelled],
        [ReservationStatus.Confirmed] = [ReservationStatus.Cancelled, ReservationStatus.Completed],
        [ReservationStatus.Cancelled] = [],
        [ReservationStatus.Completed] = [],
    };

    private static readonly ReservationStatus[] _activeStatuses =
    [
        ReservationStatus.Pending,
        ReservationStatus.Confirmed,
    ];

    private static readonly ConcurrentDictionary<int, SemaphoreSlim> _termBookingLocks = new();

    private const decimal ReservationCreatedSignalWeight = 0.3m;
    private const decimal ReservationConfirmedSignalWeight = 0.5m;
    private const decimal ReservationCompletedSignalWeight = 1.0m;

    private readonly ICurrentUserService _currentUserService;
    private readonly IValidator<ReservationCancelRequest> _cancelValidator;
    private readonly IEmailNotificationPublisher _emailNotificationPublisher;

    public ReservationService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        ICurrentUserService currentUserService,
        IValidator<ReservationInsertRequest> insertValidator,
        IValidator<ReservationUpdateRequest> updateValidator,
        IValidator<ReservationCancelRequest> cancelValidator,
        IEmailNotificationPublisher emailNotificationPublisher)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
        _currentUserService = currentUserService;
        _cancelValidator = cancelValidator;
        _emailNotificationPublisher = emailNotificationPublisher;
    }

    public override async Task<ReservationResponse> InsertAsync(ReservationInsertRequest request, CancellationToken cancellationToken = default)
    {
        var termLock = _termBookingLocks.GetOrAdd(request.TrainingTermId, static _ => new SemaphoreSlim(1, 1));
        await termLock.WaitAsync(cancellationToken);
        try
        {
            return await base.InsertAsync(request, cancellationToken);
        }
        catch (DbUpdateException)
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            var hasActiveReservation = await _dbContext.Reservations
                .AnyAsync(
                    r => r.UserAccountId == currentUserId
                         && r.TrainingTermId == request.TrainingTermId
                         && _activeStatuses.Contains(r.Status),
                    cancellationToken);

            if (hasActiveReservation)
            {
                throw new BusinessException("Već imate aktivnu rezervaciju za ovaj trening termin.");
            }

            throw;
        }
        finally
        {
            termLock.Release();
        }
    }

    protected override IQueryable<Reservation> ApplyFilter(IQueryable<Reservation> query, ReservationSearchObject search)
    {
        if (!_currentUserService.IsAdmin())
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            if (_currentUserService.IsInRole(Roles.Trainer))
            {
                query = query.Where(r => r.UserAccountId == currentUserId ||
                                         (r.TrainingTerm != null && r.TrainingTerm.Trainer != null && r.TrainingTerm.Trainer.UserAccountId == currentUserId));
            }
            else
            {
                query = query.Where(r => r.UserAccountId == currentUserId);
            }
        }
        else if (search.UserAccountId.HasValue)
        {
            query = query.Where(r => r.UserAccountId == search.UserAccountId.Value);
        }

        if (search.TrainingTermId.HasValue)
        {
            query = query.Where(r => r.TrainingTermId == search.TrainingTermId.Value);
        }

        if (search.TrainerId.HasValue)
        {
            query = query.Where(r => r.TrainingTerm != null && r.TrainingTerm.TrainerId == search.TrainerId.Value);
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

    protected override IQueryable<Reservation> ApplySearch(IQueryable<Reservation> query, ReservationSearchObject search)
    {
        if (string.IsNullOrWhiteSpace(search.Search))
        {
            return query;
        }

        var term = search.Search.Trim().ToLowerInvariant();
        return query.Where(x =>
            x.UserAccount!.FirstName.ToLower().Contains(term) ||
            x.UserAccount.LastName.ToLower().Contains(term) ||
            (x.UserAccount.FirstName + " " + x.UserAccount.LastName).ToLower().Contains(term) ||
            x.TrainingTerm!.Training!.Name.ToLower().Contains(term));
    }

    protected override async Task ValidateInsert(ReservationInsertRequest request, CancellationToken cancellationToken)
    {
        var currentUserId = _currentUserService.GetRequiredUserId();

        var user = await _dbContext.UserAccounts.FirstOrDefaultAsync(u => u.Id == currentUserId, cancellationToken);
        if (user == null || !user.IsActive || user.IsDeleted)
        {
            throw new BusinessException("Korisnički račun nije aktivan.");
        }

        var hasActiveMembership = await _dbContext.UserMemberships
            .AnyAsync(
             m => m.UserAccountId == currentUserId &&
             m.IsActive &&
             m.Status == MembershipStatus.Active &&
             m.EndDateUtc >= DateTime.UtcNow,
             cancellationToken);

        if (!hasActiveMembership)
        {
            throw new BusinessException("Potrebna je aktivna članarina za rezervaciju treninga.");
        }

        var term = await _dbContext.TrainingTerms
            .Include(t => t.Training)
            .Include(t => t.Trainer)
            .FirstOrDefaultAsync(t => t.Id == request.TrainingTermId, cancellationToken);

        if (term is null)
        {
            throw new NotFoundException($"Trening termin sa ID {request.TrainingTermId} nije pronađen.");
        }

        if (!term.IsActive)
        {
            throw new BusinessException("Ovaj trening termin nije aktivan.");
        }

        if (term.Status == TrainingTermStatus.Cancelled)
        {
            throw new BusinessException("Ovaj trening termin je otkazan.");
        }

        if (term.Status == TrainingTermStatus.Completed)
        {
            throw new BusinessException("Ne možete rezervisati završeni trening.");
        }

        if (term.StartTimeUtc <= DateTime.UtcNow)
        {
            throw new BusinessException("Ne možete rezervisati trening koji je već počeo.");
        }

        if (term.Trainer != null && term.Trainer.UserAccountId == currentUserId)
        {
            throw new BusinessException("Trener ne može rezervisati vlastiti trening.");
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
        await EnsureNoOverlappingReservationAsync(currentUserId, request.TrainingTermId, term.StartTimeUtc, term.EndTimeUtc, cancellationToken);
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

        var currentUserId = _currentUserService.GetRequiredUserId();
        bool isTrainer = _currentUserService.IsInRole(Roles.Trainer) && reservation.TrainingTerm?.Trainer?.UserAccountId == currentUserId;

        if (!_currentUserService.IsAdmin() && !isTrainer)
        {
            throw new BusinessException("Nemate pravo potvrditi ovu rezervaciju.");
        }

        EnsureValidTransition(reservation.Status, ReservationStatus.Confirmed);

        if (reservation.TrainingTerm is not null && reservation.TrainingTerm.EndTimeUtc < DateTime.UtcNow)
        {
            throw new BusinessException("Ne možete potvrditi rezervaciju za završeni trening termin.");
        }

        var previousStatus = reservation.Status;
        reservation.Status = ReservationStatus.Confirmed;
        reservation.ConfirmedAtUtc = DateTime.UtcNow;
        reservation.UpdatedAtUtc = DateTime.UtcNow;
        reservation.LastStatusChangedByUserAccountId = _currentUserService.GetRequiredUserId();

        AddStatusAudit(reservation, previousStatus, ReservationStatus.Confirmed, reason: null);

        var termStartFormatted = reservation.TrainingTerm is not null
            ? LocalTimeProvider.FormatDateTime(reservation.TrainingTerm.StartTimeUtc)
            : $"termin #{reservation.TrainingTermId}";

        _dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = reservation.UserAccountId,
            NotificationType = NotificationType.ReservationConfirmed,
            Title = "Vaša rezervacija je potvrđena",
            Content = $"Vaša rezervacija za {termStartFormatted} je uspješno potvrđena.",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow,
        });

        if (reservation.TrainingTerm?.Training is not null)
        {
            _dbContext.RecommendationSignals.Add(new RecommendationSignal
            {
                SignalType = RecommendationSignalType.ReservationConfirmed,
                Weight = ReservationConfirmedSignalWeight,
                UserAccountId = reservation.UserAccountId,
                TrainingId = reservation.TrainingTerm.TrainingId,
                TrainingCategoryId = reservation.TrainingTerm.Training.TrainingCategoryId,
                ReservationId = reservation.Id,
                CreatedAtUtc = DateTime.UtcNow,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        if (reservation.UserAccount is not null)
        {
            await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
            {
                ToEmail = reservation.UserAccount.Email,
                ToName = $"{reservation.UserAccount.FirstName} {reservation.UserAccount.LastName}",
                Subject = "Vaša rezervacija je potvrđena",
                Body = $"Poštovani, Vaša rezervacija za {termStartFormatted} je uspješno potvrđena.",
            }, cancellationToken);
        }

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

        var currentUserId = _currentUserService.GetRequiredUserId();
        bool isOwner = reservation.UserAccountId == currentUserId;
        bool isTrainer = _currentUserService.IsInRole(Roles.Trainer) && reservation.TrainingTerm?.Trainer?.UserAccountId == currentUserId;

        if (!_currentUserService.IsAdmin() && !isOwner && !isTrainer)
        {
            throw new BusinessException("Nemate pravo otkazati ovu rezervaciju.");
        }

        EnsureValidTransition(reservation.Status, ReservationStatus.Cancelled);

        ApplyCancellation(reservation, request.Reason);

        if (isOwner && reservation.TrainingTerm?.Trainer is not null
            && reservation.TrainingTerm.Trainer.UserAccountId != reservation.UserAccountId)
        {
            var memberName = reservation.UserAccount is not null
                ? $"{reservation.UserAccount.FirstName} {reservation.UserAccount.LastName}".Trim()
                : "Korisnik";
            var trainingName = reservation.TrainingTerm.Training?.Name ?? "trening";
            var termStartFormatted = LocalTimeProvider.FormatDateTime(reservation.TrainingTerm.StartTimeUtc);

            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = reservation.TrainingTerm.Trainer.UserAccountId,
                NotificationType = NotificationType.TrainerReservationCancelled,
                Title = "Rezervacija je otkazana",
                Content = $"{memberName} je otkazao/la rezervaciju za vaš termin \"{trainingName}\" ({termStartFormatted}).",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        await PublishCancellationEmailAsync(reservation, request.Reason, cancellationToken);

        _logger.LogInformation(
            "Reservation {ReservationId} cancelled by user {UserId}. Reason: {Reason}",
            reservation.Id,
            _currentUserService.GetRequiredUserId(),
            request.Reason);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task CancelAllForTrainingTermAsync(int trainingTermId, string reason, CancellationToken cancellationToken = default)
    {
        var reservations = await _dbContext.Reservations
            .Include(r => r.UserAccount)
            .Include(r => r.TrainingTerm)
            .Where(r => r.TrainingTermId == trainingTermId && _activeStatuses.Contains(r.Status))
            .ToListAsync(cancellationToken);

        foreach (var reservation in reservations)
        {
            EnsureValidTransition(reservation.Status, ReservationStatus.Cancelled);
            ApplyCancellation(reservation, reason);
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        foreach (var reservation in reservations)
        {
            await PublishCancellationEmailAsync(reservation, reason, cancellationToken);
        }

        _logger.LogInformation(
            "Cancelled {Count} reservations for TrainingTerm {TermId}.",
            reservations.Count,
            trainingTermId);
    }

    private void ApplyCancellation(Reservation reservation, string? reason)
    {
        var previousStatus = reservation.Status;
        reservation.Status = ReservationStatus.Cancelled;
        reservation.CancelledAtUtc = DateTime.UtcNow;
        reservation.CancellationReason = reason;
        reservation.UpdatedAtUtc = DateTime.UtcNow;
        reservation.LastStatusChangedByUserAccountId = _currentUserService.GetRequiredUserId();

        AddStatusAudit(reservation, previousStatus, ReservationStatus.Cancelled, reason: reason);

        var termStartFormatted = reservation.TrainingTerm is not null
            ? LocalTimeProvider.FormatDateTime(reservation.TrainingTerm.StartTimeUtc)
            : $"termin #{reservation.TrainingTermId}";

        _dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = reservation.UserAccountId,
            NotificationType = NotificationType.ReservationCancelled,
            Title = "Vaša rezervacija je otkazana",
            Content = $"Vaša rezervacija za {termStartFormatted} je otkazana. Razlog: {reason}",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow,
        });
    }

    private async Task PublishCancellationEmailAsync(Reservation reservation, string? reason, CancellationToken cancellationToken)
    {
        if (reservation.UserAccount is null)
        {
            return;
        }

        var termStartFormatted = reservation.TrainingTerm is not null
            ? LocalTimeProvider.FormatDateTime(reservation.TrainingTerm.StartTimeUtc)
            : $"termin #{reservation.TrainingTermId}";

        await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
        {
            ToEmail = reservation.UserAccount.Email,
            ToName = $"{reservation.UserAccount.FirstName} {reservation.UserAccount.LastName}",
            Subject = "Vaša rezervacija je otkazana",
            Body = $"Poštovani, Vaša rezervacija za {termStartFormatted} je otkazana. Razlog: {reason}",
        }, cancellationToken);
    }

    public async Task<ReservationResponse> CompleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var reservation = await FindTrackedReservationAsync(id, cancellationToken);

        var currentUserId = _currentUserService.GetRequiredUserId();
        bool isTrainer = _currentUserService.IsInRole(Roles.Trainer) && reservation.TrainingTerm?.Trainer?.UserAccountId == currentUserId;

        if (!_currentUserService.IsAdmin() && !isTrainer)
        {
            throw new BusinessException("Nemate pravo završiti ovu rezervaciju.");
        }

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

        var termStartFormatted = reservation.TrainingTerm is not null
            ? LocalTimeProvider.FormatDateTime(reservation.TrainingTerm.StartTimeUtc)
            : $"termin #{reservation.TrainingTermId}";

        _dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = reservation.UserAccountId,
            NotificationType = NotificationType.ReservationCompleted,
            Title = "Trening je završen",
            Content = $"Vaš trening za {termStartFormatted} je uspješno završen. Hvala na dolasku!",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow,
        });

        if (reservation.TrainingTerm?.Training is not null)
        {
            _dbContext.RecommendationSignals.Add(new RecommendationSignal
            {
                SignalType = RecommendationSignalType.ReservationCompleted,
                Weight = ReservationCompletedSignalWeight,
                UserAccountId = reservation.UserAccountId,
                TrainingId = reservation.TrainingTerm.TrainingId,
                TrainingCategoryId = reservation.TrainingTerm.Training.TrainingCategoryId,
                ReservationId = reservation.Id,
                CreatedAtUtc = DateTime.UtcNow,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Reservation {ReservationId} completed by user {UserId}.",
            reservation.Id,
            _currentUserService.GetRequiredUserId());

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task EnsureNoOverlappingReservationAsync(int userAccountId, int trainingTermId, DateTime newTermStartUtc, DateTime newTermEndUtc, CancellationToken cancellationToken = default)
    {
        var hasOverlap = await _dbContext.Reservations
        .Where(r => r.UserAccountId == userAccountId
                    && r.TrainingTermId != trainingTermId
                    && _activeStatuses.Contains(r.Status))
        .AnyAsync(
            r => r.TrainingTerm != null
                 && r.TrainingTerm.StartTimeUtc < newTermEndUtc
                 && newTermStartUtc < r.TrainingTerm.EndTimeUtc,
            cancellationToken);

        if (hasOverlap)
        {
            throw new BusinessException("Već imate rezervaciju za drugi trening termin koji se vremenski preklapa sa ovim.");
        }
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
            .Include(r => r.UserAccount)
            .Include(r => r.TrainingTerm)
                .ThenInclude(t => t!.Trainer)
            .Include(r => r.TrainingTerm)
                .ThenInclude(t => t!.Training)
            .FirstOrDefaultAsync(r => r.Id == id, cancellationToken);

        if (reservation is null)
        {
            throw new NotFoundException($"Rezervacija sa ID {id} nije pronađena.");
        }

        return reservation;
    }

    protected override async Task AfterInsert(Reservation entity, CancellationToken cancellationToken)
    {
        var term = await _dbContext.TrainingTerms
            .Include(t => t.Training)
            .Include(t => t.Trainer)
            .FirstOrDefaultAsync(t => t.Id == entity.TrainingTermId, cancellationToken);
        var termStartFormatted = term is not null ? LocalTimeProvider.FormatDateTime(term.StartTimeUtc) : $"termin #{entity.TrainingTermId}";

        _dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = entity.UserAccountId,
            NotificationType = NotificationType.ReservationCreated,
            Title = "Rezervacija je kreirana",
            Content = $"Vaša rezervacija za {termStartFormatted} je uspješno kreirana i čeka potvrdu.",
            IsRead = false,
            CreatedAtUtc = DateTime.UtcNow,
        });

        if (term?.Trainer is not null && term.Trainer.UserAccountId != entity.UserAccountId)
        {
            var member = await _dbContext.UserAccounts
                .FirstOrDefaultAsync(u => u.Id == entity.UserAccountId, cancellationToken);
            var memberName = member is not null
                ? $"{member.FirstName} {member.LastName}".Trim()
                : "Korisnik";
            var trainingName = term.Training?.Name ?? "trening";

            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = term.Trainer.UserAccountId,
                NotificationType = NotificationType.TrainerReservationCreated,
                Title = "Nova rezervacija na vašem terminu",
                Content = $"{memberName} je rezervisao/la vaš termin \"{trainingName}\" ({termStartFormatted}) i čeka potvrdu.",
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow,
            });
        }

        if (term?.Training is not null)
        {
            _dbContext.RecommendationSignals.Add(new RecommendationSignal
            {
                SignalType = RecommendationSignalType.ReservationCreated,
                Weight = ReservationCreatedSignalWeight,
                UserAccountId = entity.UserAccountId,
                TrainingId = term.TrainingId,
                TrainingCategoryId = term.Training.TrainingCategoryId,
                ReservationId = entity.Id,
                CreatedAtUtc = DateTime.UtcNow,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
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
