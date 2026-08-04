using FitBook.Model.Requests.UserMemberships;
using FitBook.Model.Responses;
using FitBook.Model.Responses.Payments;
using FitBook.Model.Responses.UserMemberships;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IUserMembershipService
    : IBaseCRUDService<UserMembershipResponse, MembershipSearchObject, UserMembershipInsertRequest, UserMembershipUpdateRequest>
{
    Task<UserMembershipResponse> CancelAsync(int id, UserMembershipCancelRequest request, CancellationToken cancellationToken = default);
    Task<UserMembershipResponse> ChangePackageAsync(int id, UserMembershipChangePackageRequest request, CancellationToken cancellationToken = default);
    Task<CreatePaymentIntentResponse> CreatePaymentIntentAsync(int id, CancellationToken cancellationToken = default);
    Task<UserMembershipResponse> ConfirmPaymentAsync(int id, CancellationToken cancellationToken = default);
    Task<PageResult<UserMembershipStatusAuditResponse>> GetStatusAuditAsync(int id, BaseSearchObject? search = null, CancellationToken cancellationToken = default);
}
