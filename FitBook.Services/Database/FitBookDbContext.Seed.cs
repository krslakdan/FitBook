using FitBook.Model.Constants;
using FitBook.Model.Enums;
using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;

namespace FitBook.Services.Database;

public partial class FitBookDbContext
{
    private void CreateSeed(ModelBuilder modelBuilder)
    {
        SeedDifficultyLevels(modelBuilder);
        SeedHalls(modelBuilder);
        SeedUserAccounts(modelBuilder); // POMJERENO IZNAD: Prvo seedamo UserAccounts zbog stranih ključeva u Trainers
        SeedTrainers(modelBuilder);
        SeedTrainingCategories(modelBuilder);
        SeedTrainings(modelBuilder);
        SeedTrainingEquipment(modelBuilder);
        SeedTrainingTerms(modelBuilder);
        SeedMembershipPackages(modelBuilder);
        SeedUserMemberships(modelBuilder);
        SeedMembershipPayments(modelBuilder);
        SeedReservations(modelBuilder);
        SeedReservationStatusAudits(modelBuilder);
        SeedSystemNotifications(modelBuilder);
        SeedNewsItems(modelBuilder);
        SeedRecommendationSignals(modelBuilder);
    }

    private void SeedDifficultyLevels(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<DifficultyLevel>().HasData(
            new DifficultyLevel { Id = 1, Name = "Beginner", SortOrder = 1, IsActive = true },
            new DifficultyLevel { Id = 2, Name = "Intermediate", SortOrder = 2, IsActive = true },
            new DifficultyLevel { Id = 3, Name = "Advanced", SortOrder = 3, IsActive = true }
        );
    }

    private void SeedHalls(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Hall>().HasData(
            new Hall { Id = 1, Name = "Main Gym Hall", Capacity = 30, LocationDescription = "Ground Floor, Zone A", IsActive = true },
            new Hall { Id = 2, Name = "Yoga & Pilates Studio", Capacity = 15, LocationDescription = "First Floor, Zone B", IsActive = true },
            new Hall { Id = 3, Name = "Spinning Room", Capacity = 20, LocationDescription = "First Floor, Zone C", IsActive = true }
        );
    }

    private void SeedUserAccounts(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserAccount>().HasData(
            new UserAccount
            {
                Id = 1,
                FirstName = "System",
                LastName = "Administrator",
                Email = "admin@fitbook.com",
                PhoneNumber = "+38761111222",
                Username = "desktop",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Admin,
                ProfileImageUrl = "uploads/users/admin.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 2,
                FirstName = "John",
                LastName = "Client",
                Email = "user@fitbook.com",
                PhoneNumber = "+38761333444",
                Username = "mobile",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/john.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            // KORISNIČKI NALOZI ZA TRENERE (Sinhronizovani sa tabelom Trainers)
            new UserAccount
            {
                Id = 3,
                FirstName = "John",
                LastName = "Doe",
                Email = "johndoe@fitbook.com",
                PhoneNumber = "+38761555001",
                Username = "johndoe",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Trainer,
                ProfileImageUrl = "uploads/trainers/trainer1.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 4,
                FirstName = "Jane",
                LastName = "Smith",
                Email = "janesmith@fitbook.com",
                PhoneNumber = "+38761555002",
                Username = "janesmith",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Trainer,
                ProfileImageUrl = "uploads/trainers/trainer2.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 5,
                FirstName = "Mike",
                LastName = "Jones",
                Email = "mikejones@fitbook.com",
                PhoneNumber = "+38761555003",
                Username = "mikejones",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Trainer,
                ProfileImageUrl = "uploads/trainers/trainer3.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 6,
                FirstName = "Guest",
                LastName = "User",
                Email = "guest@fitbook.com",
                PhoneNumber = "+38761777888",
                Username = "guest_user",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Guest,
                ProfileImageUrl = "uploads/users/guest.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            }
        );
    }

    private void SeedTrainers(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Trainer>().HasData(
            new Trainer
            {
                Id = 1,
                FirstName = "John",
                LastName = "Doe",
                Specialization = "Strength & Conditioning",
                Biography = "Certified trainer with 8+ years of experience in athletic training.",
                ImageUrl = "uploads/trainers/trainer1.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 3 // <--- VEZA sa UserAccount Id = 3
            },
            new Trainer
            {
                Id = 2,
                FirstName = "Jane",
                LastName = "Smith",
                Specialization = "Yoga & Pilates",
                Biography = "Passionate about helping people find balance and flexibility.",
                ImageUrl = "uploads/trainers/trainer2.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 4 // <--- VEZA sa UserAccount Id = 4
            },
            new Trainer
            {
                Id = 3,
                FirstName = "Mike",
                LastName = "Jones",
                Specialization = "Cardio & HIIT",
                Biography = "Energy-packed HIIT workouts to keep you burning calories.",
                ImageUrl = "uploads/trainers/trainer3.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 5 // <--- VEZA sa UserAccount Id = 5
            }
        );
    }

    private void SeedTrainingCategories(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TrainingCategory>().HasData(
            new TrainingCategory { Id = 1, Name = "Cardio", Description = "Workouts designed to improve heart health and stamina.", IsActive = true },
            new TrainingCategory { Id = 2, Name = "Strength", Description = "Resistance training designed to build muscle mass.", IsActive = true },
            new TrainingCategory { Id = 3, Name = "Mind & Body", Description = "Yoga, stretching, and mindfulness practices.", IsActive = true }
        );
    }

    private void SeedTrainings(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Training>().HasData(
            new Training
            {
                Id = 1,
                Name = "HIIT Blast",
                Description = "High Intensity Interval Training to boost metabolism.",
                DurationMinutes = 45,
                MaxParticipants = 20,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 10, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 1,
                DifficultyLevelId = 2
            },
            new Training
            {
                Id = 2,
                Name = "Power Lifting",
                Description = "Learn and execute proper barbell techniques.",
                DurationMinutes = 60,
                MaxParticipants = 10,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 10, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 2,
                DifficultyLevelId = 3
            },
            new Training
            {
                Id = 3,
                Name = "Vinyasa Yoga",
                Description = "Flowing sequences of yoga poses with breath control.",
                DurationMinutes = 60,
                MaxParticipants = 15,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 10, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 3,
                DifficultyLevelId = 1
            }
        );
    }

    private void SeedTrainingEquipment(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TrainingEquipment>().HasData(
            new TrainingEquipment { Id = 1, Name = "Kettlebell", IsRequired = true, Note = "Recommended 8kg-16kg", TrainingId = 1 },
            new TrainingEquipment { Id = 2, Name = "Barbell Set", IsRequired = true, Note = "Belts provided in hall", TrainingId = 2 },
            new TrainingEquipment { Id = 3, Name = "Yoga Mat", IsRequired = false, Note = "Mats are available in studio, or bring your own", TrainingId = 3 }
        );
    }

    private void SeedTrainingTerms(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TrainingTerm>().HasData(
            new TrainingTerm
            {
                Id = 1,
                StartTimeUtc = new DateTime(2026, 6, 25, 10, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 6, 25, 10, 45, 0, DateTimeKind.Utc),
                MaxParticipants = 20,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 6, 20, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 1,
                TrainerId = 3, // Mike Jones
                HallId = 3
            },
            new TrainingTerm
            {
                Id = 2,
                StartTimeUtc = new DateTime(2026, 6, 26, 12, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 6, 26, 13, 0, 0, DateTimeKind.Utc),
                MaxParticipants = 10,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 6, 20, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 2,
                TrainerId = 1, // John Doe
                HallId = 1
            },
            new TrainingTerm
            {
                Id = 3,
                StartTimeUtc = new DateTime(2026, 7, 5, 8, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 5, 9, 0, 0, DateTimeKind.Utc),
                MaxParticipants = 15,
                Status = TrainingTermStatus.Scheduled,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 6, 20, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 3,
                TrainerId = 2, // Jane Smith
                HallId = 2
            }
        );
    }

    private void SeedMembershipPackages(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<MembershipPackage>().HasData(
            new MembershipPackage
            {
                Id = 1,
                Name = "1 Month Basic",
                DurationDays = 30,
                Price = 50.00m,
                SavingsAmount = 0.00m,
                IncludedBenefits = "Access to main hall, 3 group trainings per week.",
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new MembershipPackage
            {
                Id = 2,
                Name = "3 Month Premium",
                DurationDays = 90,
                Price = 120.00m,
                SavingsAmount = 30.00m,
                IncludedBenefits = "Unlimited group trainings, sauna access, 1 free personal session.",
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            }
        );
    }

    private void SeedUserMemberships(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<UserMembership>().HasData(
            new UserMembership
            {
                Id = 1,
                StartDateUtc = new DateTime(2026, 6, 1, 0, 0, 0, DateTimeKind.Utc),
                EndDateUtc = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc),
                NextPaymentDateUtc = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc),
                Status = MembershipStatus.Active,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 5, 30, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 2,
                MembershipPackageId = 1
            }
        );
    }

    private void SeedMembershipPayments(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<MembershipPayment>().HasData(
            new MembershipPayment
            {
                Id = 1,
                Amount = 50.00m,
                Currency = "BAM",
                PaymentProvider = "Stripe",
                PaymentIntentId = "pi_1234567890",
                TransactionReference = "tx_998877",
                Status = PaymentStatus.Completed,
                CreatedAtUtc = new DateTime(2026, 5, 30, 10, 0, 0, DateTimeKind.Utc),
                PaidAtUtc = new DateTime(2026, 5, 30, 10, 5, 0, DateTimeKind.Utc),
                UserMembershipId = 1,
                UserAccountId = 2
            }
        );
    }

    private void SeedReservations(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Reservation>().HasData(
            new Reservation
            {
                Id = 1,
                Status = ReservationStatus.Completed,
                ReservedAtUtc = new DateTime(2026, 6, 21, 15, 0, 0, DateTimeKind.Utc),
                ConfirmedAtUtc = new DateTime(2026, 6, 21, 15, 10, 0, DateTimeKind.Utc),
                CompletedAtUtc = new DateTime(2026, 6, 25, 11, 0, 0, DateTimeKind.Utc),
                UserAccountId = 2,
                TrainingTermId = 1
            },
            new Reservation
            {
                Id = 2,
                Status = ReservationStatus.Completed,
                ReservedAtUtc = new DateTime(2026, 6, 22, 16, 0, 0, DateTimeKind.Utc),
                ConfirmedAtUtc = new DateTime(2026, 6, 22, 16, 5, 0, DateTimeKind.Utc),
                CompletedAtUtc = new DateTime(2026, 6, 26, 13, 0, 0, DateTimeKind.Utc),
                UserAccountId = 2,
                TrainingTermId = 2
            },
            new Reservation
            {
                Id = 3,
                Status = ReservationStatus.Confirmed,
                ReservedAtUtc = new DateTime(2026, 6, 23, 10, 0, 0, DateTimeKind.Utc),
                ConfirmedAtUtc = new DateTime(2026, 6, 23, 10, 15, 0, DateTimeKind.Utc),
                UserAccountId = 2,
                TrainingTermId = 3
            }
        );
    }

    private void SeedReservationStatusAudits(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ReservationStatusAudit>().HasData(
            new ReservationStatusAudit
            {
                Id = 1,
                PreviousStatus = ReservationStatus.Pending,
                NewStatus = ReservationStatus.Confirmed,
                ChangedAtUtc = new DateTime(2026, 6, 21, 15, 10, 0, DateTimeKind.Utc),
                Reason = "Auto-confirmed on successful payment and active membership check",
                ReservationId = 1,
                ChangedByUserAccountId = 1 // Admin
            },
            new ReservationStatusAudit
            {
                Id = 2,
                PreviousStatus = ReservationStatus.Confirmed,
                NewStatus = ReservationStatus.Completed,
                ChangedAtUtc = new DateTime(2026, 6, 25, 11, 0, 0, DateTimeKind.Utc),
                Reason = "Marked as completed after class finish",
                ReservationId = 1,
                ChangedByUserAccountId = 5 // Mike Jones (Trainer za termin 1)
            }
        );
    }

    private void SeedSystemNotifications(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SystemNotification>().HasData(
            new SystemNotification
            {
                Id = 1,
                Title = "Reservation Confirmed",
                Content = "Your reservation for Vinyasa Yoga has been successfully confirmed.",
                IsRead = false,
                CreatedAtUtc = new DateTime(2026, 6, 23, 10, 15, 0, DateTimeKind.Utc),
                NotificationType = NotificationType.ReservationConfirmed,
                UserAccountId = 2
            }
        );
    }

    private void SeedNewsItems(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<NewsItem>().HasData(
            new NewsItem
            {
                Id = 1,
                Title = "Grand Opening of our Yoga Studio!",
                Content = "We are thrilled to announce that our new premium Yoga & Pilates studio on the first floor is now open for bookings.",
                ImageUrl = "uploads/news/yoga_opening.jpg", // POPRAVLJENA DOSLJEDNOST PUTANJE
                PublishedAtUtc = new DateTime(2026, 6, 15, 9, 0, 0, DateTimeKind.Utc),
                IsActive = true
            }
        );
    }

    private void SeedRecommendationSignals(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<RecommendationSignal>().HasData(
            new RecommendationSignal
            {
                Id = 1,
                SignalType = RecommendationSignalType.ReservationCompleted,
                Weight = 1.0m,
                CreatedAtUtc = new DateTime(2026, 6, 25, 11, 0, 0, DateTimeKind.Utc),
                UserAccountId = 2,
                TrainingId = 1,
                TrainingCategoryId = 1,
                ReservationId = 1
            },
            new RecommendationSignal
            {
                Id = 2,
                SignalType = RecommendationSignalType.ReservationCompleted,
                Weight = 1.0m,
                CreatedAtUtc = new DateTime(2026, 6, 26, 13, 0, 0, DateTimeKind.Utc),
                UserAccountId = 2,
                TrainingId = 2,
                TrainingCategoryId = 2,
                ReservationId = 2
            }
        );
    }
}