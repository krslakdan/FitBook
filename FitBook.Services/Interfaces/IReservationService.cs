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
    Task EnsureNoActiveReservationForTermAsync(int userAccountId, int trainingTermId, CancellationToken cancellationToken = default);
}
