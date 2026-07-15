using FitBook.Model.Enums;
using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services.Database;

public static class DatabaseInitializer
{
    private const int MaxMigrationAttempts = 10;

    public static async Task InitializeAsync(FitBookDbContext dbContext, ILogger logger, CancellationToken cancellationToken = default)
    {
        await MigrateWithRetryAsync(dbContext, logger, cancellationToken);
        await EnsureUpcomingTrainingTermsAsync(dbContext, logger, cancellationToken);
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

    private static async Task EnsureUpcomingTrainingTermsAsync(FitBookDbContext dbContext, ILogger logger, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;

        var hasUpcomingScheduledTerms = await dbContext.TrainingTerms
            .AnyAsync(t => t.Status == TrainingTermStatus.Scheduled && t.StartTimeUtc > now, cancellationToken);

        if (hasUpcomingScheduledTerms)
        {
            return;
        }

        var trainings = await dbContext.Trainings.Where(t => t.IsActive).OrderBy(t => t.Id).ToListAsync(cancellationToken);
        var trainers = await dbContext.Trainers.Where(t => t.IsActive && t.IsAvailable).OrderBy(t => t.Id).ToListAsync(cancellationToken);
        var halls = await dbContext.Halls.Where(h => h.IsActive).OrderBy(h => h.Id).ToListAsync(cancellationToken);

        if (trainings.Count == 0 || trainers.Count == 0 || halls.Count == 0)
        {
            logger.LogWarning("Skipping dynamic training term seeding: reference data (trainings/trainers/halls) is not available yet.");
            return;
        }

        var startOffsets = new[] { TimeSpan.FromHours(20), TimeSpan.FromDays(3), TimeSpan.FromDays(9) };
        var demoTerms = new List<TrainingTerm>();

        for (var i = 0; i < startOffsets.Length; i++)
        {
            var training = trainings[i % trainings.Count];
            var trainer = trainers[i % trainers.Count];
            var hall = halls[i % halls.Count];
            var startTimeUtc = now.Add(startOffsets[i]);

            demoTerms.Add(new TrainingTerm
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
            });
        }

        dbContext.TrainingTerms.AddRange(demoTerms);
        await dbContext.SaveChangesAsync(cancellationToken);

        var demoUser = await dbContext.UserAccounts.FirstOrDefaultAsync(u => u.Username == "mobile", cancellationToken);
        if (demoUser is not null)
        {
            dbContext.Reservations.Add(new Reservation
            {
                Status = ReservationStatus.Confirmed,
                ReservedAtUtc = now,
                ConfirmedAtUtc = now,
                UserAccountId = demoUser.Id,
                TrainingTermId = demoTerms[0].Id,
            });

            await dbContext.SaveChangesAsync(cancellationToken);
        }

        logger.LogInformation(
            "Seeded {Count} upcoming training term(s) relative to {Now:O} so reservation, reminder, and recommender flows remain testable.",
            demoTerms.Count,
            now);
    }
}
