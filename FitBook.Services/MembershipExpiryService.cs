using FitBook.Model.Enums;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class MembershipExpiryService : IMembershipExpiryService
{
    private readonly FitBookDbContext _dbContext;
    private readonly ILogger<MembershipExpiryService> _logger;

    public MembershipExpiryService(
        FitBookDbContext dbContext,
        ILogger<MembershipExpiryService> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task<int> ExpireDueMembershipsAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;

        var dueMemberships = await _dbContext.UserMemberships
            .Where(m => m.Status == MembershipStatus.Active
                        && !m.IsDeleted
                        && m.EndDateUtc <= now)
            .ToListAsync(cancellationToken);

        if (dueMemberships.Count == 0)
        {
            return 0;
        }

        foreach (var membership in dueMemberships)
        {
            membership.Status = MembershipStatus.Expired;
            membership.IsActive = false;
            membership.UpdatedAtUtc = now;

            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = membership.UserAccountId,
                NotificationType = NotificationType.MembershipExpired,
                Title = "Članarina je istekla",
                Content = "Vaša članarina je istekla. Obnovite je kako biste nastavili rezervisati treninge.",
                IsRead = false,
                CreatedAtUtc = now,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Expired {Count} membership(s) past their end date.", dueMemberships.Count);

        return dueMemberships.Count;
    }
}
