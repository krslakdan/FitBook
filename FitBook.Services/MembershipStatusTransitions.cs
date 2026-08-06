using FitBook.Model.Enums;
using FitBook.Model.Exceptions;

namespace FitBook.Services;

public static class MembershipStatusTransitions
{
    private static readonly Dictionary<MembershipStatus, MembershipStatus[]> Allowed = new()
    {
        [MembershipStatus.Pending] = [MembershipStatus.Active, MembershipStatus.Cancelled],
        [MembershipStatus.Active] = [MembershipStatus.Cancelled, MembershipStatus.Expired],
        [MembershipStatus.Cancelled] = [],
        [MembershipStatus.Expired] = [],
    };

    public static bool IsAllowed(MembershipStatus from, MembershipStatus to)
    {
        return Allowed.TryGetValue(from, out var allowed) && allowed.Contains(to);
    }

    public static void EnsureAllowed(MembershipStatus from, MembershipStatus to)
    {
        if (!IsAllowed(from, to))
        {
            throw new BusinessException($"Nije moguća tranzicija statusa članarine iz '{from}' u '{to}'.");
        }
    }
}
