using FitBook.Common.Services.Time;
using FitBook.Model.Enums;
using FitBook.Model.Messages;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FitBook.Services.Messaging;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class ReminderService : IReminderService
{
    private readonly FitBookDbContext _dbContext;
    private readonly IEmailNotificationPublisher _emailNotificationPublisher;
    private readonly ILogger<ReminderService> _logger;

    public ReminderService(
        FitBookDbContext dbContext,
        IEmailNotificationPublisher emailNotificationPublisher,
        ILogger<ReminderService> logger)
    {
        _dbContext = dbContext;
        _emailNotificationPublisher = emailNotificationPublisher;
        _logger = logger;
    }

    public async Task<int> SendDueReservationRemindersAsync(TimeSpan reminderLeadTime, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var reminderCutoff = now.Add(reminderLeadTime);

        var dueReservations = await _dbContext.Reservations
            .Include(r => r.UserAccount)
            .Include(r => r.TrainingTerm)
            .Where(r => r.Status == ReservationStatus.Confirmed
                        && r.ReminderSentAtUtc == null
                        && r.TrainingTerm != null
                        && r.TrainingTerm.StartTimeUtc > now
                        && r.TrainingTerm.StartTimeUtc <= reminderCutoff)
            .ToListAsync(cancellationToken);

        if (dueReservations.Count == 0)
        {
            return 0;
        }

        foreach (var reservation in dueReservations)
        {
            reservation.ReminderSentAtUtc = now;

            var termStartFormatted = reservation.TrainingTerm is not null
                ? LocalTimeProvider.FormatDateTime(reservation.TrainingTerm.StartTimeUtc)
                : $"termin #{reservation.TrainingTermId}";

            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = reservation.UserAccountId,
                NotificationType = NotificationType.ReservationReminder,
                Title = "Podsjetnik: trening uskoro počinje",
                Content = $"Podsjetnik: Vaš trening zakazan za {termStartFormatted} uskoro počinje.",
                IsRead = false,
                CreatedAtUtc = now,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        foreach (var reservation in dueReservations)
        {
            if (reservation.UserAccount is null)
            {
                continue;
            }

            var termStartFormatted = reservation.TrainingTerm is not null
                ? LocalTimeProvider.FormatDateTime(reservation.TrainingTerm.StartTimeUtc)
                : $"termin #{reservation.TrainingTermId}";

            await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
            {
                ToEmail = reservation.UserAccount.Email,
                ToName = $"{reservation.UserAccount.FirstName} {reservation.UserAccount.LastName}",
                Subject = "Podsjetnik: trening uskoro počinje",
                Body = $"Poštovani, ovo je podsjetnik da Vaš trening zakazan za {termStartFormatted} uskoro počinje.",
            }, cancellationToken);
        }

        _logger.LogInformation(
            "Sent {Count} reservation reminder(s) for trainings starting within {LeadTime}.",
            dueReservations.Count,
            reminderLeadTime);

        return dueReservations.Count;
    }

    public async Task<int> SendDueTrainerTermRemindersAsync(TimeSpan reminderLeadTime, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var reminderCutoff = now.Add(reminderLeadTime);

        var dueTerms = await _dbContext.TrainingTerms
            .Include(t => t.Training)
            .Include(t => t.Trainer)
            .Where(t => t.Status == TrainingTermStatus.Scheduled
                        && t.IsActive
                        && t.TrainerReminderSentAtUtc == null
                        && t.StartTimeUtc > now
                        && t.StartTimeUtc <= reminderCutoff)
            .ToListAsync(cancellationToken);

        if (dueTerms.Count == 0)
        {
            return 0;
        }

        foreach (var term in dueTerms)
        {
            term.TrainerReminderSentAtUtc = now;

            if (term.Trainer is null)
            {
                continue;
            }

            var termStartFormatted = LocalTimeProvider.FormatDateTime(term.StartTimeUtc);
            var trainingName = term.Training?.Name ?? "trening";

            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = term.Trainer.UserAccountId,
                NotificationType = NotificationType.TrainerTermReminder,
                Title = "Podsjetnik: termin uskoro počinje",
                Content = $"Podsjetnik: vaš termin \"{trainingName}\" zakazan za {termStartFormatted} uskoro počinje.",
                IsRead = false,
                CreatedAtUtc = now,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);

        _logger.LogInformation(
            "Sent {Count} trainer term reminder(s) for terms starting within {LeadTime}.",
            dueTerms.Count,
            reminderLeadTime);

        return dueTerms.Count;
    }

    public async Task<int> SendDueMembershipExpiryRemindersAsync(TimeSpan reminderLeadTime, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var reminderCutoff = now.Add(reminderLeadTime);

        var dueMemberships = await _dbContext.UserMemberships
            .Include(m => m.UserAccount)
            .Where(m => m.Status == MembershipStatus.Active
                        && m.IsActive
                        && !m.IsDeleted
                        && m.ExpiryReminderSentAtUtc == null
                        && m.EndDateUtc > now
                        && m.EndDateUtc <= reminderCutoff)
            .ToListAsync(cancellationToken);

        if (dueMemberships.Count == 0)
        {
            return 0;
        }

        foreach (var membership in dueMemberships)
        {
            membership.ExpiryReminderSentAtUtc = now;

            var endFormatted = LocalTimeProvider.FormatDate(membership.EndDateUtc);

            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = membership.UserAccountId,
                NotificationType = NotificationType.MembershipExpiringSoon,
                Title = "Članarina uskoro ističe",
                Content = $"Vaša članarina ističe {endFormatted}. Obnovite je na vrijeme kako biste nastavili rezervisati treninge.",
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

            var endFormatted = LocalTimeProvider.FormatDate(membership.EndDateUtc);

            await _emailNotificationPublisher.PublishAsync(new EmailNotificationMessage
            {
                ToEmail = membership.UserAccount.Email,
                ToName = $"{membership.UserAccount.FirstName} {membership.UserAccount.LastName}",
                Subject = "Vaša članarina uskoro ističe",
                Body = $"Poštovani, Vaša FitBook članarina ističe {endFormatted}. Obnovite je na vrijeme kako biste nastavili koristiti treninge.",
            }, cancellationToken);
        }

        _logger.LogInformation(
            "Sent {Count} membership expiry reminder(s) for memberships expiring within {LeadTime}.",
            dueMemberships.Count,
            reminderLeadTime);

        return dueMemberships.Count;
    }
}
