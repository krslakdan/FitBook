namespace FitBook.Services;

public interface IReservationService
{
    Task EnsureNoActiveReservationForTermAsync(int userAccountId, int trainingTermId, CancellationToken cancellationToken = default);
}
