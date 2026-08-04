using FitBook.Model.Requests.Reservations;
using FitBook.Model.Responses;
using FitBook.Model.Responses.Reservations;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database.Entities;

namespace FitBook.Services.Interfaces;

public interface IReservationService
    : IBaseCRUDService<ReservationResponse, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
{
    Task<ReservationResponse> ConfirmAsync(int id, CancellationToken cancellationToken = default);
    Task<ReservationResponse> CancelAsync(int id, ReservationCancelRequest request, CancellationToken cancellationToken = default);
    Task<ReservationResponse> CompleteAsync(int id, CancellationToken cancellationToken = default);
    Task<PageResult<ReservationStatusAuditResponse>> GetStatusAuditAsync(int id, BaseSearchObject? search = null, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Reservation>> CancelAllForTrainingTermAsync(int trainingTermId, string reason, CancellationToken cancellationToken = default);
    Task PublishCancellationEmailsAsync(IReadOnlyList<Reservation> reservations, string? reason, CancellationToken cancellationToken = default);
    Task EnsureNoActiveReservationForTermAsync(int userAccountId, int trainingTermId, CancellationToken cancellationToken = default);
    Task EnsureNoOverlappingReservationAsync(int userAccountId, int trainingTermId, DateTime newTermStartUtc, DateTime newTermEndUtc, CancellationToken cancellationToken=default);
}
