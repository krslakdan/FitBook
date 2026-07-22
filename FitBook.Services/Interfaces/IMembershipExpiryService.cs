namespace FitBook.Services.Interfaces;

public interface IMembershipExpiryService
{
    Task<int> ExpireDueMembershipsAsync(CancellationToken cancellationToken = default);
}
