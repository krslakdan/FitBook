using FitBook.Model.Enums;
using FitBook.Model.Exceptions;
using FitBook.Model.Requests.Reservations;
using FitBook.Model.Requests.TrainingTerms;
using FitBook.Model.Responses.TrainingTerms;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class TrainingTermService
    : BaseCRUDService<TrainingTerm, TrainingTermResponse, TrainingTermSearchObject, TrainingTermInsertRequest, TrainingTermUpdateRequest>,
      ITrainingTermService
{
    private static readonly ReservationStatus[] _activeReservationStatuses =
    [
        ReservationStatus.Pending,
        ReservationStatus.Confirmed,
    ];

    private readonly ICurrentUserService _currentUserService;
    private readonly IValidator<TrainingTermCancelRequest> _cancelValidator;

    public TrainingTermService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<TrainingTermInsertRequest> insertValidator,
        IValidator<TrainingTermUpdateRequest> updateValidator,
        IValidator<TrainingTermCancelRequest> cancelValidator,
        ICurrentUserService currentUserService)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
        _cancelValidator = cancelValidator;
        _currentUserService = currentUserService;
    }

    protected override IQueryable<TrainingTerm> ApplyFilter(IQueryable<TrainingTerm> query, TrainingTermSearchObject search)
    {
        if (search.TrainingId.HasValue)
        {
            query = query.Where(x => x.TrainingId == search.TrainingId.Value);
        }

        if (search.TrainerId.HasValue)
        {
            query = query.Where(x => x.TrainerId == search.TrainerId.Value);
        }

        if (search.HallId.HasValue)
        {
            query = query.Where(x => x.HallId == search.HallId.Value);
        }

        if (search.Status.HasValue)
        {
            query = query.Where(x => x.Status == search.Status.Value);
        }

        if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        if (search.StartFromUtc.HasValue)
        {
            query = query.Where(x => x.StartTimeUtc >= search.StartFromUtc.Value);
        }

        if (search.StartToUtc.HasValue)
        {
            query = query.Where(x => x.StartTimeUtc <= search.StartToUtc.Value);
        }

        return query;
    }

    protected override async Task ValidateInsert(TrainingTermInsertRequest request, CancellationToken cancellationToken)
    {
        await ValidateForeignKeys(request.TrainingId, request.TrainerId, request.HallId, request.MaxParticipants, cancellationToken);
        await CheckTrainerOverlap(request.TrainerId, excludeTermId: null, request.StartTimeUtc, request.EndTimeUtc, cancellationToken);
        await CheckHallOverlap(request.HallId, excludeTermId: null, request.StartTimeUtc, request.EndTimeUtc, cancellationToken);
    }

    protected override async Task ValidateUpdate(int id, TrainingTermUpdateRequest request, TrainingTerm entity, CancellationToken cancellationToken)
    {
        await ValidateTrainerAndHall(request.TrainerId, request.HallId, request.MaxParticipants, cancellationToken);

        var activeReservationCount = await _dbContext.Reservations
            .CountAsync(r => r.TrainingTermId == id && _activeReservationStatuses.Contains(r.Status), cancellationToken);

        if (request.MaxParticipants < activeReservationCount)
        {
            throw new BusinessException($"Maksimalan broj učesnika ({request.MaxParticipants}) ne može biti manji od broja postojećih aktivnih rezervacija ({activeReservationCount}) za ovaj termin.");
        }

        // Block time/trainer changes if there are active reservations
        bool timeOrTrainerChanged =
            entity.StartTimeUtc != request.StartTimeUtc ||
            entity.EndTimeUtc != request.EndTimeUtc ||
            entity.TrainerId != request.TrainerId;

        if (timeOrTrainerChanged && activeReservationCount > 0)
        {
            throw new BusinessException("Nije moguće promijeniti vrijeme termina ili trenera dok postoje aktivne rezervacije. Otkazite termin umjesto toga.");
        }

        await CheckTrainerOverlap(request.TrainerId, excludeTermId: id, request.StartTimeUtc, request.EndTimeUtc, cancellationToken);
        await CheckHallOverlap(request.HallId, excludeTermId: id, request.StartTimeUtc, request.EndTimeUtc, cancellationToken);
    }

    protected override Task BeforeInsert(TrainingTermInsertRequest request, TrainingTerm entity, CancellationToken cancellationToken)
    {
        entity.Status = TrainingTermStatus.Scheduled;
        return Task.CompletedTask;
    }

    protected override async Task ValidateDelete(int id, TrainingTerm entity, CancellationToken cancellationToken)
    {
        var hasReservations = await _dbContext.Reservations
            .AnyAsync(r => r.TrainingTermId == id, cancellationToken);

        if (hasReservations)
        {
            throw new BusinessException("Termin treninga ne može biti obrisan jer postoje rezervacije vezane za njega (aktivne ili historijske). Otkazite termin umjesto brisanja kako bi se sačuvali historijski podaci.");
        }
    }

    public async Task<TrainingTermResponse> CancelAsync(int id, TrainingTermCancelRequest request, CancellationToken cancellationToken = default)
    {
        await _cancelValidator.ValidateAndThrowAsync(request, cancellationToken);

        var term = await _dbContext.TrainingTerms
            .FirstOrDefaultAsync(t => t.Id == id, cancellationToken);

        if (term is null)
        {
            throw new NotFoundException($"TrainingTerm with id {id} was not found.");
        }

        if (term.Status == TrainingTermStatus.Cancelled)
        {
            throw new BusinessException("Termin treninga je već otkazan.");
        }

        if (term.Status == TrainingTermStatus.Completed)
        {
            throw new BusinessException("Nije moguće otkazati završeni termin treninga.");
        }

        term.Status = TrainingTermStatus.Cancelled;
        term.IsActive = false;
        term.UpdatedAtUtc = DateTime.UtcNow;

        // Cascade cancel all active reservations for this term
        await CancelAllActiveReservationsForTermAsync(term, request.Reason, cancellationToken);

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "TrainingTerm {TermId} cancelled. Reason: {Reason}",
            id,
            request.Reason);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<TrainingTermResponse> CompleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var term = await _dbContext.TrainingTerms
            .FirstOrDefaultAsync(t => t.Id == id, cancellationToken);

        if (term is null)
        {
            throw new NotFoundException($"TrainingTerm with id {id} was not found.");
        }

        if (term.Status == TrainingTermStatus.Completed)
        {
            throw new BusinessException("Termin treninga je već završen.");
        }

        if (term.Status == TrainingTermStatus.Cancelled)
        {
            throw new BusinessException("Nije moguće završiti otkazani termin treninga.");
        }

        if (term.EndTimeUtc > DateTime.UtcNow)
        {
            throw new BusinessException("Nije moguće označiti termin kao završen dok još nije isteklo plansko vrijeme završetka.");
        }

        term.Status = TrainingTermStatus.Completed;
        term.UpdatedAtUtc = DateTime.UtcNow;

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("TrainingTerm {TermId} marked as completed.", id);

        return await GetByIdAsync(id, cancellationToken);
    }

    private async Task CancelAllActiveReservationsForTermAsync(TrainingTerm term, string? reason, CancellationToken cancellationToken)
    {
        var activeReservations = await _dbContext.Reservations
            .Where(r => r.TrainingTermId == term.Id && _activeReservationStatuses.Contains(r.Status))
            .ToListAsync(cancellationToken);

        var termStartFormatted = term.StartTimeUtc.ToString("yyyy-MM-dd HH:mm") + " UTC";

        var currentUserId = _currentUserService.GetRequiredUserId();

        foreach (var reservation in activeReservations)
        {
            var previousStatus = reservation.Status;
            reservation.Status = ReservationStatus.Cancelled;
            reservation.CancelledAtUtc = DateTime.UtcNow;
            reservation.CancellationReason = reason ?? "Termin treninga je otkazan od strane administratora.";
            reservation.UpdatedAtUtc = DateTime.UtcNow;

            _dbContext.ReservationStatusAudits.Add(new ReservationStatusAudit
            {
                ReservationId = reservation.Id,
                PreviousStatus = previousStatus,
                NewStatus = ReservationStatus.Cancelled,
                ChangedAtUtc = DateTime.UtcNow,
                Reason = reservation.CancellationReason,
                CreatedAtUtc = DateTime.UtcNow,
                ChangedByUserAccountId = currentUserId,
            });

            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = reservation.UserAccountId,
                NotificationType = NotificationType.TrainingTermCancelled,
                Title = "Termin treninga je otkazan",
                Content = $"Termin treninga zakazan za {termStartFormatted} je otkazan. Vaša rezervacija je automatski otkazana." +
                          (string.IsNullOrWhiteSpace(reason) ? string.Empty : $" Razlog: {reason}"),
                IsRead = false,
                CreatedAtUtc = DateTime.UtcNow,
            });
        }

        _logger.LogInformation(
            "Cancelled {Count} active reservations for TrainingTerm {TermId}.",
            activeReservations.Count,
            term.Id);
    }

    private async Task ValidateForeignKeys(int trainingId, int trainerId, int hallId, int maxParticipants, CancellationToken cancellationToken)
    {
        var training = await _dbContext.Trainings
            .FirstOrDefaultAsync(t => t.Id == trainingId, cancellationToken);

        if (training is null)
        {
            throw new NotFoundException($"Training with id {trainingId} was not found.");
        }

        if (!training.IsActive)
        {
            throw new BusinessException($"Trening '{training.Name}' je neaktivan. Nije moguće zakazati termin za neaktivan trening.");
        }

        await ValidateTrainerAndHall(trainerId, hallId, maxParticipants, cancellationToken);
    }

    private async Task ValidateTrainerAndHall(int trainerId, int hallId, int maxParticipants, CancellationToken cancellationToken)
    {
        var trainer = await _dbContext.Trainers
            .FirstOrDefaultAsync(t => t.Id == trainerId, cancellationToken);

        if (trainer is null)
        {
            throw new NotFoundException($"Trainer with id {trainerId} was not found.");
        }

        if (!trainer.IsActive)
        {
            throw new BusinessException($"Trener '{trainer.FirstName} {trainer.LastName}' je neaktivan. Nije moguće dodijeliti neaktivnog trenera terminu.");
        }

        if (!trainer.IsAvailable)
        {
            throw new BusinessException($"Trener '{trainer.FirstName} {trainer.LastName}' trenutno nije dostupan. Nije moguće dodijeliti nedostupnog trenera terminu.");
        }

        var hall = await _dbContext.Halls
            .FirstOrDefaultAsync(h => h.Id == hallId, cancellationToken);

        if (hall is null)
        {
            throw new NotFoundException($"Hall with id {hallId} was not found.");
        }

        if (!hall.IsActive)
        {
            throw new BusinessException($"Sala '{hall.Name}' je neaktivna. Nije moguće zakazati termin u neaktivnoj sali.");
        }

        if (maxParticipants > hall.Capacity)
        {
            throw new BusinessException($"Maksimalan broj učesnika ({maxParticipants}) premašuje kapacitet sale '{hall.Name}' ({hall.Capacity} mjesta).");
        }
    }

    private async Task CheckTrainerOverlap(int trainerId, int? excludeTermId, DateTime startUtc, DateTime endUtc, CancellationToken cancellationToken)
    {
        var query = _dbContext.TrainingTerms
            .Where(t => t.TrainerId == trainerId
                        && t.Status != TrainingTermStatus.Cancelled
                        && t.StartTimeUtc < endUtc
                        && startUtc < t.EndTimeUtc);

        if (excludeTermId.HasValue)
        {
            query = query.Where(t => t.Id != excludeTermId.Value);
        }

        var hasOverlap = await query.AnyAsync(cancellationToken);

        if (hasOverlap)
        {
            throw new BusinessException("Trener već ima zakazan termin koji se vremenski preklapa sa ovim terminom.");
        }
    }

    private async Task CheckHallOverlap(int hallId, int? excludeTermId, DateTime startUtc, DateTime endUtc, CancellationToken cancellationToken)
    {
        var query = _dbContext.TrainingTerms
            .Where(t => t.HallId == hallId
                        && t.Status != TrainingTermStatus.Cancelled
                        && t.StartTimeUtc < endUtc
                        && startUtc < t.EndTimeUtc);

        if (excludeTermId.HasValue)
        {
            query = query.Where(t => t.Id != excludeTermId.Value);
        }

        var hasOverlap = await query.AnyAsync(cancellationToken);

        if (hasOverlap)
        {
            throw new BusinessException("U odabranoj sali već postoji termin treninga koji se vremenski preklapa sa ovim terminom.");
        }
    }
}
