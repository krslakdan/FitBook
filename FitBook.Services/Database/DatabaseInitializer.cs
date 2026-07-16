using FitBook.Model.Constants;
using FitBook.Model.Enums;
using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services.Database;

public static class DatabaseInitializer
{
    private const int MaxMigrationAttempts = 10;
    private const decimal ReservationCreatedSignalWeight = 0.3m;
    private const decimal ReservationConfirmedSignalWeight = 0.5m;

    public static async Task InitializeAsync(FitBookDbContext dbContext, ILogger logger, CancellationToken cancellationToken = default)
    {
        await MigrateWithRetryAsync(dbContext, logger, cancellationToken);

        try
        {
            await SeedDemoDataAsync(dbContext, logger, cancellationToken);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Failed to seed/refresh demo data. The application will continue to start; existing data is unaffected.");
        }
    }

    private static async Task MigrateWithRetryAsync(FitBookDbContext dbContext, ILogger logger, CancellationToken cancellationToken)
    {
        var delay = TimeSpan.FromSeconds(3);

        for (var attempt = 1; attempt <= MaxMigrationAttempts; attempt++)
        {
            try
            {
                await dbContext.Database.MigrateAsync(cancellationToken);
                logger.LogInformation("Database migration completed successfully.");
                return;
            }
            catch (Exception ex)
            {
                if (attempt == MaxMigrationAttempts)
                {
                    logger.LogError(ex, "Database migration failed after {MaxAttempts} attempts. Giving up.", MaxMigrationAttempts);
                    throw;
                }

                logger.LogWarning(
                    ex,
                    "Database migration attempt {Attempt}/{MaxAttempts} failed (database may still be starting up). Retrying in {Delay}.",
                    attempt,
                    MaxMigrationAttempts,
                    delay);

                await Task.Delay(delay, cancellationToken);
            }
        }
    }

    private static async Task SeedDemoDataAsync(FitBookDbContext dbContext, ILogger logger, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;

        var mobileUser = await dbContext.UserAccounts.FirstOrDefaultAsync(u => u.Username == "mobile", cancellationToken);
        if (mobileUser is null)
        {
            logger.LogWarning("Skipping demo data seeding: seed user 'mobile' was not found.");
            return;
        }

        var trainings = await dbContext.Trainings.Where(t => t.IsActive).OrderBy(t => t.Id).ToListAsync(cancellationToken);
        var trainers = await dbContext.Trainers.Where(t => t.IsActive && t.IsAvailable).OrderBy(t => t.Id).ToListAsync(cancellationToken);
        var halls = await dbContext.Halls.Where(h => h.IsActive).OrderBy(h => h.Id).ToListAsync(cancellationToken);
        var capacityFillUsers = await dbContext.UserAccounts
            .Where(u => u.Role == Roles.User && u.Username != "mobile" && u.IsActive)
            .OrderBy(u => u.Id)
            .ToListAsync(cancellationToken);

        if (trainings.Count == 0 || trainers.Count == 0 || halls.Count == 0)
        {
            logger.LogWarning("Skipping demo data seeding: reference data (trainings/trainers/halls) is not available yet.");
            return;
        }

        await EnsureActiveMembershipAsync(dbContext, mobileUser, now, logger, cancellationToken);
        await EnsureReminderScenarioAsync(dbContext, mobileUser, trainings, trainers, halls, now, logger, cancellationToken);
        await EnsurePendingConfirmScenarioAsync(dbContext, mobileUser, trainings, trainers, halls, now, logger, cancellationToken);
        await EnsureCompletableScenarioAsync(dbContext, mobileUser, trainings, trainers, halls, now, logger, cancellationToken);
        await EnsureOpenBookableTermsAsync(dbContext, trainings, trainers, halls, now, logger, cancellationToken);

        if (capacityFillUsers.Count > 0)
        {
            await EnsureFullCapacityScenarioAsync(dbContext, capacityFillUsers, trainings, trainers, halls, now, logger, cancellationToken);
        }
    }

    private static async Task EnsureActiveMembershipAsync(FitBookDbContext dbContext, UserAccount mobileUser, DateTime now, ILogger logger, CancellationToken cancellationToken)
    {
        var activeMembership = await dbContext.UserMemberships
            .Where(m => m.UserAccountId == mobileUser.Id && m.Status == MembershipStatus.Active)
            .OrderByDescending(m => m.Id)
            .FirstOrDefaultAsync(cancellationToken);

        if (activeMembership is null)
        {
            var package = await dbContext.MembershipPackages.Where(p => p.IsActive).OrderBy(p => p.Id).FirstOrDefaultAsync(cancellationToken);
            if (package is null)
            {
                return;
            }

            dbContext.UserMemberships.Add(new UserMembership
            {
                Status = MembershipStatus.Active,
                IsActive = true,
                StartDateUtc = now,
                EndDateUtc = now.AddDays(package.DurationDays),
                NextPaymentDateUtc = now.AddDays(package.DurationDays),
                CreatedAtUtc = now,
                UserAccountId = mobileUser.Id,
                MembershipPackageId = package.Id,
            });

            await dbContext.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Created a fresh active membership for the demo client.");
            return;
        }

        if (activeMembership.EndDateUtc <= now)
        {
            activeMembership.StartDateUtc = now;
            activeMembership.EndDateUtc = now.AddDays(30);
            activeMembership.NextPaymentDateUtc = now.AddDays(30);
            activeMembership.UpdatedAtUtc = now;

            await dbContext.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Extended the demo client's active membership so it remains valid.");
        }
    }

    private static async Task EnsureReminderScenarioAsync(
        FitBookDbContext dbContext, UserAccount mobileUser, List<Training> trainings, List<Trainer> trainers, List<Hall> halls,
        DateTime now, ILogger logger, CancellationToken cancellationToken)
    {
        var hasReminderCandidate = await dbContext.Reservations.AnyAsync(
            r => r.UserAccountId == mobileUser.Id
                 && r.Status == ReservationStatus.Confirmed
                 && r.TrainingTerm!.StartTimeUtc > now
                 && r.TrainingTerm.StartTimeUtc <= now.AddHours(24),
            cancellationToken);

        if (hasReminderCandidate)
        {
            return;
        }

        var training = trainings[0];
        var term = BuildTerm(training, trainers[0], halls[0], now.AddHours(20), now);
        dbContext.TrainingTerms.Add(term);
        await dbContext.SaveChangesAsync(cancellationToken);

        var reservation = new Reservation
        {
            Status = ReservationStatus.Confirmed,
            ReservedAtUtc = now,
            ConfirmedAtUtc = now,
            UserAccountId = mobileUser.Id,
            TrainingTermId = term.Id,
        };
        dbContext.Reservations.Add(reservation);
        await dbContext.SaveChangesAsync(cancellationToken);

        AddConfirmationSideEffects(dbContext, mobileUser.Id, reservation.Id, training, term, now);
        await dbContext.SaveChangesAsync(cancellationToken);

        logger.LogInformation("Seeded a reminder-eligible confirmed reservation starting at {StartTimeUtc:O}.", term.StartTimeUtc);
    }

    private static async Task EnsurePendingConfirmScenarioAsync(
        FitBookDbContext dbContext, UserAccount mobileUser, List<Training> trainings, List<Trainer> trainers, List<Hall> halls,
        DateTime now, ILogger logger, CancellationToken cancellationToken)
    {
        var hasPendingCandidate = await dbContext.Reservations.AnyAsync(
            r => r.UserAccountId == mobileUser.Id
                 && r.Status == ReservationStatus.Pending
                 && r.TrainingTerm!.StartTimeUtc > now,
            cancellationToken);

        if (hasPendingCandidate)
        {
            return;
        }

        var training = trainings[1 % trainings.Count];
        var trainer = trainers.Find(t => t.Id == 1) ?? trainers[0];
        var term = BuildTerm(training, trainer, halls[1 % halls.Count], now.AddDays(3), now);
        dbContext.TrainingTerms.Add(term);
        await dbContext.SaveChangesAsync(cancellationToken);

        var reservation = new Reservation
        {
            Status = ReservationStatus.Pending,
            ReservedAtUtc = now,
            UserAccountId = mobileUser.Id,
            TrainingTermId = term.Id,
        };
        dbContext.Reservations.Add(reservation);
        await dbContext.SaveChangesAsync(cancellationToken);

        dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = mobileUser.Id,
            NotificationType = NotificationType.ReservationCreated,
            Title = "Rezervacija je kreirana",
            Content = $"Vaša rezervacija za {training.Name} je uspješno kreirana i čeka potvrdu.",
            IsRead = false,
            CreatedAtUtc = now,
        });
        dbContext.RecommendationSignals.Add(new RecommendationSignal
        {
            SignalType = RecommendationSignalType.ReservationCreated,
            Weight = ReservationCreatedSignalWeight,
            UserAccountId = mobileUser.Id,
            TrainingId = training.Id,
            TrainingCategoryId = training.TrainingCategoryId,
            ReservationId = reservation.Id,
            CreatedAtUtc = now,
        });
        await dbContext.SaveChangesAsync(cancellationToken);

        logger.LogInformation("Seeded a pending reservation awaiting confirmation for term starting at {StartTimeUtc:O}.", term.StartTimeUtc);
    }

    private static async Task EnsureCompletableScenarioAsync(
        FitBookDbContext dbContext, UserAccount mobileUser, List<Training> trainings, List<Trainer> trainers, List<Hall> halls,
        DateTime now, ILogger logger, CancellationToken cancellationToken)
    {
        var hasCompletableCandidate = await dbContext.Reservations.AnyAsync(
            r => r.UserAccountId == mobileUser.Id
                 && r.Status == ReservationStatus.Confirmed
                 && r.TrainingTerm!.Status == TrainingTermStatus.Scheduled
                 && r.TrainingTerm.EndTimeUtc <= now,
            cancellationToken);

        if (hasCompletableCandidate)
        {
            return;
        }

        var training = trainings[2 % trainings.Count];
        var startTimeUtc = now.AddHours(-3);
        var term = BuildTerm(training, trainers[2 % trainers.Count], halls[2 % halls.Count], startTimeUtc, now);
        dbContext.TrainingTerms.Add(term);
        await dbContext.SaveChangesAsync(cancellationToken);

        var reservation = new Reservation
        {
            Status = ReservationStatus.Confirmed,
            ReservedAtUtc = startTimeUtc.AddDays(-2),
            ConfirmedAtUtc = startTimeUtc.AddDays(-2).AddMinutes(10),
            UserAccountId = mobileUser.Id,
            TrainingTermId = term.Id,
        };
        dbContext.Reservations.Add(reservation);
        await dbContext.SaveChangesAsync(cancellationToken);

        AddConfirmationSideEffects(dbContext, mobileUser.Id, reservation.Id, training, term, now);
        await dbContext.SaveChangesAsync(cancellationToken);

        logger.LogInformation("Seeded a completable confirmed reservation for a term that ended at {EndTimeUtc:O}.", term.EndTimeUtc);
    }

    private static async Task EnsureOpenBookableTermsAsync(
        FitBookDbContext dbContext, List<Training> trainings, List<Trainer> trainers, List<Hall> halls,
        DateTime now, ILogger logger, CancellationToken cancellationToken)
    {
        const int desiredOpenTerms = 2;

        var openTermsCount = await dbContext.TrainingTerms.CountAsync(
            t => t.Status == TrainingTermStatus.Scheduled
                 && t.StartTimeUtc > now
                 && !t.Reservations.Any(r => r.Status == ReservationStatus.Pending || r.Status == ReservationStatus.Confirmed),
            cancellationToken);

        var missing = desiredOpenTerms - openTermsCount;
        if (missing <= 0)
        {
            return;
        }

        var offsets = new[] { TimeSpan.FromDays(9), TimeSpan.FromDays(16) };
        for (var i = 0; i < missing && i < offsets.Length; i++)
        {
            var training = trainings[i % trainings.Count];
            var term = BuildTerm(training, trainers[i % trainers.Count], halls[i % halls.Count], now.Add(offsets[i]), now);
            dbContext.TrainingTerms.Add(term);
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        logger.LogInformation("Topped up open bookable training terms (added {Count}).", Math.Min(missing, offsets.Length));
    }
  
    private static async Task EnsureFullCapacityScenarioAsync(
        FitBookDbContext dbContext, List<UserAccount> capacityFillUsers, List<Training> trainings, List<Trainer> trainers, List<Hall> halls,
        DateTime now, ILogger logger, CancellationToken cancellationToken)
    {
        var hasFullTerm = await dbContext.TrainingTerms.AnyAsync(
            t => t.Status == TrainingTermStatus.Scheduled
                 && t.StartTimeUtc > now
                 && t.Reservations.Count(r => r.Status == ReservationStatus.Pending || r.Status == ReservationStatus.Confirmed) >= t.MaxParticipants,
            cancellationToken);

        if (hasFullTerm)
        {
            return;
        }

        var training = trainings[3 % trainings.Count];
        var term = BuildTerm(training, trainers[0], halls[0], now.AddDays(6), now);
        term.MaxParticipants = capacityFillUsers.Count;
        dbContext.TrainingTerms.Add(term);
        await dbContext.SaveChangesAsync(cancellationToken);

        foreach (var user in capacityFillUsers)
        {
            var reservation = new Reservation
            {
                Status = ReservationStatus.Confirmed,
                ReservedAtUtc = now,
                ConfirmedAtUtc = now,
                UserAccountId = user.Id,
                TrainingTermId = term.Id,
            };
            dbContext.Reservations.Add(reservation);
            await dbContext.SaveChangesAsync(cancellationToken);

            AddConfirmationSideEffects(dbContext, user.Id, reservation.Id, training, term, now);
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        logger.LogInformation(
            "Seeded a fully booked training term ({Count} participants) starting at {StartTimeUtc:O}.",
            capacityFillUsers.Count,
            term.StartTimeUtc);
    }

    private static void AddConfirmationSideEffects(FitBookDbContext dbContext, int userAccountId, int reservationId, Training training, TrainingTerm term, DateTime now)
    {
        var termStartFormatted = term.StartTimeUtc.ToString("yyyy-MM-dd HH:mm") + " UTC";

        dbContext.SystemNotifications.Add(new SystemNotification
        {
            UserAccountId = userAccountId,
            NotificationType = NotificationType.ReservationConfirmed,
            Title = "Vaša rezervacija je potvrđena",
            Content = $"Vaša rezervacija za {termStartFormatted} je uspješno potvrđena.",
            IsRead = false,
            CreatedAtUtc = now,
        });

        dbContext.RecommendationSignals.Add(new RecommendationSignal
        {
            SignalType = RecommendationSignalType.ReservationConfirmed,
            Weight = ReservationConfirmedSignalWeight,
            UserAccountId = userAccountId,
            TrainingId = training.Id,
            TrainingCategoryId = training.TrainingCategoryId,
            ReservationId = reservationId,
            CreatedAtUtc = now,
        });
    }

    private static TrainingTerm BuildTerm(Training training, Trainer trainer, Hall hall, DateTime startTimeUtc, DateTime now)
    {
        return new TrainingTerm
        {
            StartTimeUtc = startTimeUtc,
            EndTimeUtc = startTimeUtc.AddMinutes(training.DurationMinutes),
            MaxParticipants = Math.Min(training.MaxParticipants, hall.Capacity),
            Status = TrainingTermStatus.Scheduled,
            IsActive = true,
            CreatedAtUtc = now,
            TrainingId = training.Id,
            TrainerId = trainer.Id,
            HallId = hall.Id,
        };
    }
}
