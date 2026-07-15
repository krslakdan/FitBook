using FitBook.Model.Requests.Reservations;
using FitBook.Model.Responses.Reservations;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IReservationService
    : IBaseCRUDService<ReservationResponse, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
{
    Task<ReservationResponse> ConfirmAsync(int id, CancellationToken cancellationToken = default);
    Task<ReservationResponse> CancelAsync(int id, ReservationCancelRequest request, CancellationToken cancellationToken = default);
    Task<ReservationResponse> CompleteAsync(int id, CancellationToken cancellationToken = default);
    Task CancelAllForTrainingTermAsync(int trainingTermId, string reason, CancellationToken cancellationToken = default);
    Task<int> SendDueRemindersAsync(TimeSpan reminderLeadTime, CancellationToken cancellationToken = default);
    Task EnsureNoActiveReservationForTermAsync(int userAccountId, int trainingTermId, CancellationToken cancellationToken = default);
    Task EnsureNoOverlappingReservationAsync(int userAccountId, int trainingTermId, DateTime newTermStartUtc, DateTime newTermEndUtc, CancellationToken cancellationToken=default);
}
