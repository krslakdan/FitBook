using FitBook.Model.Enums;
using FitBook.Model.Messages;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FitBook.Services.Messaging;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class MembershipExpiryService : IMembershipExpiryService
{
    private readonly FitBookDbContext _dbContext;
    private readonly IEmailNotificationPublisher _emailNotificationPublisher;
    private readonly ILogger<MembershipExpiryService> _logger;

    public MembershipExpiryService(
        FitBookDbContext dbContext,
        IEmailNotificationPublisher emailNotificationPublisher,
        ILogger<MembershipExpiryService> logger)
    {
        _dbContext = dbContext;
        _emailNotificationPublisher = emailNotificationPublisher;
        _logger = logger;
    }

    public async Task<int> ExpireDueMembershipsAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;

        var dueMemberships = await _dbContext.UserMemberships
            .Include(m => m.UserAccount)
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
            var previousStatus = membership.Status;

            if (!MembershipStatusTransitions.IsAllowed(previousStatus, MembershipStatus.Expired))
            {
                _logger.LogWarning(
                    "Skipping membership {MembershipId}: transition from {PreviousStatus} to Expired is not allowed.",
                    membership.Id,
                    previousStatus);
                continue;
            }

            membership.Status = MembershipStatus.Expired;
            membership.IsActive = false;
            membership.NextPaymentDateUtc = null;
            membership.UpdatedAtUtc = now;

            _dbContext.UserMembershipStatusAudits.Add(new UserMembershipStatusAudit
            {
                UserMembershipId = membership.Id,
                PreviousStatus = previousStatus,
                NewStatus = MembershipStatus.Expired,
                ChangedAtUtc = now,
                Reason = "Automatski istek članarine.",
                CreatedAtUtc = now,
            });

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

        foreach (var membership in dueMemberships)
        {
            if (membership.UserAccount is null)
            {
                continue;
            }

            await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
            {
                ToEmail = membership.UserAccount.Email,
                ToName = $"{membership.UserAccount.FirstName} {membership.UserAccount.LastName}",
                Subject = "Vaša članarina je istekla",
                Body = $"Poštovani {membership.UserAccount.FirstName}, Vaša FitBook članarina je istekla. Obnovite je kako biste nastavili rezervisati treninge.",
            }, cancellationToken);
        }

        _logger.LogInformation("Expired {Count} membership(s) past their end date.", dueMemberships.Count);

        return dueMemberships.Count;
    }
}
