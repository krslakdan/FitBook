namespace FitBook.Services.Interfaces;

public interface IReservationService
{
    Task EnsureNoActiveReservationForTermAsync(int userAccountId, int trainingTermId, CancellationToken cancellationToken = default);
}
