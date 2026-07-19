using FitBook.Model.Responses.Payments;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using MapsterMapper;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class MembershipPaymentService
    : BaseReadService<MembershipPayment, MembershipPaymentResponse, MembershipPaymentSearchObject>,
      IMembershipPaymentService
{
    private readonly ICurrentUserService _currentUserService;

    public MembershipPaymentService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        ICurrentUserService currentUserService)
        : base(dbContext, mapper, loggerFactory)
    {
        _currentUserService = currentUserService;
    }

    protected override IQueryable<MembershipPayment> ApplyFilter(IQueryable<MembershipPayment> query, MembershipPaymentSearchObject search)
    {
        if (!_currentUserService.IsAdmin())
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(x => x.UserAccountId == currentUserId);
        }
        else if (search.UserAccountId.HasValue)
        {
            query = query.Where(x => x.UserAccountId == search.UserAccountId.Value);
        }

        if (search.UserMembershipId.HasValue)
        {
            query = query.Where(x => x.UserMembershipId == search.UserMembershipId.Value);
        }

        if (search.Status.HasValue)
        {
            query = query.Where(x => x.Status == search.Status.Value);
        }

        return query;
    }
}
