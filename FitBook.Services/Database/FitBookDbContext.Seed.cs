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
        SeedSpecializations(modelBuilder);
        SeedHalls(modelBuilder);
        SeedUserAccounts(modelBuilder);
        SeedTrainers(modelBuilder);
        SeedTrainingCategories(modelBuilder);
        SeedTrainings(modelBuilder);
        SeedEquipment(modelBuilder);
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

    private void SeedSpecializations(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Specialization>().HasData(
            new Specialization { Id = 1, Name = "Strength & Conditioning", IsActive = true },
            new Specialization { Id = 2, Name = "Yoga & Pilates", IsActive = true },
            new Specialization { Id = 3, Name = "Cardio & HIIT", IsActive = true },
            new Specialization { Id = 4, Name = "CrossFit", IsActive = true },
            new Specialization { Id = 5, Name = "Bodybuilding", IsActive = true }
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
                FirstName = "Amina",
                LastName = "Hodžić",
                Email = "amina@fitbook.com",
                PhoneNumber = "+38761555010",
                Username = "amina",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/guest.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 5, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 7,
                FirstName = "Emir",
                LastName = "Halilović",
                Email = "emir@fitbook.com",
                PhoneNumber = "+38761555011",
                Username = "emir",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/john.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 5, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 8,
                FirstName = "Lejla",
                LastName = "Bećirović",
                Email = "lejla@fitbook.com",
                PhoneNumber = "+38761555012",
                Username = "lejla",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/jane.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 5, 0, 0, 0, DateTimeKind.Utc)
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
                SpecializationId = 1,
                Biography = "Certified trainer with 8+ years of experience in athletic training.",
                ImageUrl = "uploads/trainers/trainer1.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 3
            },
            new Trainer
            {
                Id = 2,
                FirstName = "Jane",
                LastName = "Smith",
                SpecializationId = 2,
                Biography = "Passionate about helping people find balance and flexibility.",
                ImageUrl = "uploads/trainers/trainer2.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 4
            },
            new Trainer
            {
                Id = 3,
                FirstName = "Mike",
                LastName = "Jones",
                SpecializationId = 3,
                Biography = "Energy-packed HIIT workouts to keep you burning calories.",
                ImageUrl = "uploads/trainers/trainer3.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 5
            }
        );
    }

    private void SeedTrainingCategories(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TrainingCategory>().HasData(
            new TrainingCategory { Id = 1, Name = "Cardio", Description = "Workouts designed to improve heart health and stamina.", IsActive = true },
            new TrainingCategory { Id = 2, Name = "Strength", Description = "Resistance training designed to build muscle mass.", IsActive = true },
            new TrainingCategory { Id = 3, Name = "Mind & Body", Description = "Yoga, stretching, and mindfulness practices.", IsActive = true },
            new TrainingCategory { Id = 4, Name = "Recovery & Mobility", Description = "Low-impact recovery, stretching, and mobility work.", IsActive = true },
            new TrainingCategory { Id = 5, Name = "Combat Sports", Description = "Boxing and martial-arts inspired conditioning.", IsActive = true }
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
            },
            new Training
            {
                Id = 4,
                Name = "Foam Rolling & Mobility",
                Description = "Guided self-myofascial release and joint mobility drills.",
                DurationMinutes = 30,
                MaxParticipants = 12,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 4,
                DifficultyLevelId = 1
            },
            new Training
            {
                Id = 5,
                Name = "Boxing Fundamentals",
                Description = "Footwork, combinations, and pad work for beginners and intermediates.",
                DurationMinutes = 50,
                MaxParticipants = 14,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 5,
                DifficultyLevelId = 2
            },
            new Training
            {
                Id = 6,
                Name = "Morning Run Club",
                Description = "Coached outdoor interval running session to start the day.",
                DurationMinutes = 40,
                MaxParticipants = 25,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 1,
                DifficultyLevelId = 1
            },
            new Training
            {
                Id = 7,
                Name = "Deadlift Technique",
                Description = "Barbell deadlift form clinic for lifters ready to add weight safely.",
                DurationMinutes = 60,
                MaxParticipants = 8,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 2,
                DifficultyLevelId = 3
            }
        );
    }

    private void SeedEquipment(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Equipment>().HasData(
            new Equipment { Id = 1, Name = "Kettlebell", IsActive = true },
            new Equipment { Id = 2, Name = "Barbell Set", IsActive = true },
            new Equipment { Id = 3, Name = "Yoga Mat", IsActive = true },
            new Equipment { Id = 4, Name = "Foam Roller", IsActive = true },
            new Equipment { Id = 5, Name = "Boxing Gloves", IsActive = true }
        );
    }

    private void SeedTrainingEquipment(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TrainingEquipment>().HasData(
            new TrainingEquipment { Id = 1, EquipmentId = 1, IsRequired = true, Note = "Recommended 8kg-16kg", TrainingId = 1 },
            new TrainingEquipment { Id = 2, EquipmentId = 2, IsRequired = true, Note = "Belts provided in hall", TrainingId = 2 },
            new TrainingEquipment { Id = 3, EquipmentId = 3, IsRequired = false, Note = "Mats are available in studio, or bring your own", TrainingId = 3 },
            new TrainingEquipment { Id = 4, EquipmentId = 4, IsRequired = true, Note = "Provided in studio", TrainingId = 4 },
            new TrainingEquipment { Id = 5, EquipmentId = 5, IsRequired = true, Note = "Bring your own or rent at front desk", TrainingId = 5 }
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
                TrainerId = 3,
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
                TrainerId = 1,
                HallId = 1
            },
            new TrainingTerm
            {
                Id = 3,
                StartTimeUtc = new DateTime(2026, 7, 5, 8, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 5, 9, 0, 0, DateTimeKind.Utc),
                MaxParticipants = 15,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 6, 20, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 3,
                TrainerId = 2,
                HallId = 2
            },
            new TrainingTerm
            {
                Id = 4,
                StartTimeUtc = new DateTime(2026, 6, 28, 9, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 6, 28, 9, 40, 0, DateTimeKind.Utc),
                MaxParticipants = 25,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 6, 21, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 6,
                TrainerId = 3,
                HallId = 1
            },
            new TrainingTerm
            {
                Id = 5,
                StartTimeUtc = new DateTime(2026, 7, 2, 18, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 2, 18, 50, 0, DateTimeKind.Utc),
                MaxParticipants = 14,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 6, 25, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 5,
                TrainerId = 1,
                HallId = 1
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
            },
            new MembershipPackage
            {
                Id = 3,
                Name = "1 Year VIP",
                DurationDays = 365,
                Price = 400.00m,
                SavingsAmount = 200.00m,
                IncludedBenefits = "Unlimited group trainings, sauna access, 4 free personal sessions, priority booking.",
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
            },
            new UserMembership
            {
                Id = 2,
                StartDateUtc = new DateTime(2026, 4, 1, 0, 0, 0, DateTimeKind.Utc),
                EndDateUtc = new DateTime(2026, 5, 1, 0, 0, 0, DateTimeKind.Utc),
                NextPaymentDateUtc = null,
                Status = MembershipStatus.Expired,
                IsActive = false,
                CreatedAtUtc = new DateTime(2026, 3, 30, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 6,
                MembershipPackageId = 1
            },
            new UserMembership
            {
                Id = 3,
                StartDateUtc = new DateTime(2026, 5, 1, 0, 0, 0, DateTimeKind.Utc),
                EndDateUtc = new DateTime(2026, 6, 1, 0, 0, 0, DateTimeKind.Utc),
                NextPaymentDateUtc = null,
                Status = MembershipStatus.Cancelled,
                IsActive = false,
                CreatedAtUtc = new DateTime(2026, 4, 28, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 7,
                MembershipPackageId = 2
            },
            new UserMembership
            {
                Id = 4,
                StartDateUtc = new DateTime(2026, 7, 10, 0, 0, 0, DateTimeKind.Utc),
                EndDateUtc = new DateTime(2026, 7, 10, 0, 0, 0, DateTimeKind.Utc),
                NextPaymentDateUtc = null,
                Status = MembershipStatus.Pending,
                IsActive = false,
                CreatedAtUtc = new DateTime(2026, 7, 10, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 8,
                MembershipPackageId = 3
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
                Currency = "USD",
                PaymentProvider = "Stripe",
                PaymentIntentId = "pi_1234567890",
                TransactionReference = "tx_998877",
                Status = PaymentStatus.Completed,
                CreatedAtUtc = new DateTime(2026, 5, 30, 10, 0, 0, DateTimeKind.Utc),
                PaidAtUtc = new DateTime(2026, 5, 30, 10, 5, 0, DateTimeKind.Utc),
                UserMembershipId = 1,
                UserAccountId = 2
            },
            new MembershipPayment
            {
                Id = 2,
                Amount = 120.00m,
                Currency = "USD",
                PaymentProvider = "Stripe",
                PaymentIntentId = "pi_seed_0000000002",
                TransactionReference = "tx_998878",
                Status = PaymentStatus.Refunded,
                CreatedAtUtc = new DateTime(2026, 5, 1, 9, 0, 0, DateTimeKind.Utc),
                PaidAtUtc = new DateTime(2026, 5, 1, 9, 5, 0, DateTimeKind.Utc),
                RefundedAtUtc = new DateTime(2026, 6, 1, 12, 0, 0, DateTimeKind.Utc),
                RefundAmount = 120.00m,
                UserMembershipId = 3,
                UserAccountId = 7
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
                Status = ReservationStatus.Completed,
                ReservedAtUtc = new DateTime(2026, 6, 23, 10, 0, 0, DateTimeKind.Utc),
                ConfirmedAtUtc = new DateTime(2026, 6, 23, 10, 15, 0, DateTimeKind.Utc),
                CompletedAtUtc = new DateTime(2026, 7, 5, 9, 5, 0, DateTimeKind.Utc),
                UserAccountId = 2,
                TrainingTermId = 3
            },
            new Reservation
            {
                Id = 4,
                Status = ReservationStatus.Completed,
                ReservedAtUtc = new DateTime(2026, 6, 27, 8, 0, 0, DateTimeKind.Utc),
                ConfirmedAtUtc = new DateTime(2026, 6, 27, 8, 10, 0, DateTimeKind.Utc),
                CompletedAtUtc = new DateTime(2026, 6, 28, 9, 40, 0, DateTimeKind.Utc),
                UserAccountId = 6,
                TrainingTermId = 4
            },
            new Reservation
            {
                Id = 5,
                Status = ReservationStatus.Completed,
                ReservedAtUtc = new DateTime(2026, 7, 1, 12, 0, 0, DateTimeKind.Utc),
                ConfirmedAtUtc = new DateTime(2026, 7, 1, 12, 5, 0, DateTimeKind.Utc),
                CompletedAtUtc = new DateTime(2026, 7, 2, 18, 50, 0, DateTimeKind.Utc),
                UserAccountId = 7,
                TrainingTermId = 5
            },
            new Reservation
            {
                Id = 6,
                Status = ReservationStatus.Cancelled,
                ReservedAtUtc = new DateTime(2026, 6, 26, 14, 0, 0, DateTimeKind.Utc),
                CancelledAtUtc = new DateTime(2026, 6, 27, 9, 0, 0, DateTimeKind.Utc),
                CancellationReason = "Promjena rasporeda korisnika.",
                UserAccountId = 8,
                TrainingTermId = 4
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
                ChangedByUserAccountId = 1
            },
            new ReservationStatusAudit
            {
                Id = 2,
                PreviousStatus = ReservationStatus.Confirmed,
                NewStatus = ReservationStatus.Completed,
                ChangedAtUtc = new DateTime(2026, 6, 25, 11, 0, 0, DateTimeKind.Utc),
                Reason = "Marked as completed after class finish",
                ReservationId = 1,
                ChangedByUserAccountId = 5
            },
            new ReservationStatusAudit
            {
                Id = 3,
                PreviousStatus = ReservationStatus.Confirmed,
                NewStatus = ReservationStatus.Completed,
                ChangedAtUtc = new DateTime(2026, 7, 5, 9, 5, 0, DateTimeKind.Utc),
                Reason = "Marked as completed after class finish",
                ReservationId = 3,
                ChangedByUserAccountId = 4
            },
            new ReservationStatusAudit
            {
                Id = 4,
                PreviousStatus = ReservationStatus.Confirmed,
                NewStatus = ReservationStatus.Completed,
                ChangedAtUtc = new DateTime(2026, 6, 28, 9, 40, 0, DateTimeKind.Utc),
                Reason = "Marked as completed after class finish",
                ReservationId = 4,
                ChangedByUserAccountId = 5
            },
            new ReservationStatusAudit
            {
                Id = 5,
                PreviousStatus = ReservationStatus.Confirmed,
                NewStatus = ReservationStatus.Completed,
                ChangedAtUtc = new DateTime(2026, 7, 2, 18, 50, 0, DateTimeKind.Utc),
                Reason = "Marked as completed after class finish",
                ReservationId = 5,
                ChangedByUserAccountId = 3
            },
            new ReservationStatusAudit
            {
                Id = 6,
                PreviousStatus = ReservationStatus.Pending,
                NewStatus = ReservationStatus.Cancelled,
                ChangedAtUtc = new DateTime(2026, 6, 27, 9, 0, 0, DateTimeKind.Utc),
                Reason = "Promjena rasporeda korisnika.",
                ReservationId = 6,
                ChangedByUserAccountId = 8
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
            },
            new SystemNotification
            {
                Id = 2,
                Title = "Plaćanje članarine uspješno",
                Content = "Vaša članarina je uspješno plaćena i sada je aktivna.",
                IsRead = true,
                ReadAtUtc = new DateTime(2026, 5, 30, 11, 0, 0, DateTimeKind.Utc),
                CreatedAtUtc = new DateTime(2026, 5, 30, 10, 5, 0, DateTimeKind.Utc),
                NotificationType = NotificationType.MembershipPaid,
                UserAccountId = 2
            },
            new SystemNotification
            {
                Id = 3,
                Title = "Članarina je istekla",
                Content = "Vaša članarina je istekla.",
                IsRead = false,
                CreatedAtUtc = new DateTime(2026, 5, 1, 0, 5, 0, DateTimeKind.Utc),
                NotificationType = NotificationType.MembershipExpired,
                UserAccountId = 6
            },
            new SystemNotification
            {
                Id = 4,
                Title = "Članarina je otkazana",
                Content = "Vaša članarina je otkazana. Izvršen je povrat sredstava.",
                IsRead = false,
                CreatedAtUtc = new DateTime(2026, 6, 1, 12, 0, 0, DateTimeKind.Utc),
                NotificationType = NotificationType.MembershipCancelled,
                UserAccountId = 7
            },
            new SystemNotification
            {
                Id = 5,
                Title = "Trening je završen",
                Content = "Vaš trening za Morning Run Club je uspješno završen. Hvala na dolasku!",
                IsRead = true,
                ReadAtUtc = new DateTime(2026, 6, 28, 12, 0, 0, DateTimeKind.Utc),
                CreatedAtUtc = new DateTime(2026, 6, 28, 9, 40, 0, DateTimeKind.Utc),
                NotificationType = NotificationType.ReservationCompleted,
                UserAccountId = 6
            },
            new SystemNotification
            {
                Id = 6,
                Title = "Trening je završen",
                Content = "Vaš trening za Boxing Fundamentals je uspješno završen. Hvala na dolasku!",
                IsRead = false,
                CreatedAtUtc = new DateTime(2026, 7, 2, 18, 50, 0, DateTimeKind.Utc),
                NotificationType = NotificationType.ReservationCompleted,
                UserAccountId = 7
            },
            new SystemNotification
            {
                Id = 7,
                Title = "Vaša rezervacija je otkazana",
                Content = "Vaša rezervacija za Morning Run Club je otkazana. Razlog: Promjena rasporeda korisnika.",
                IsRead = false,
                CreatedAtUtc = new DateTime(2026, 6, 27, 9, 0, 0, DateTimeKind.Utc),
                NotificationType = NotificationType.ReservationCancelled,
                UserAccountId = 8
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
                ImageUrl = "uploads/news/yoga_opening.jpg",
                PublishedAtUtc = new DateTime(2026, 6, 15, 9, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new NewsItem
            {
                Id = 2,
                Title = "Nova oprema za snagu je stigla!",
                Content = "Prošireni smo novim setovima utega i spravama za trening snage u glavnoj dvorani. Dođite isprobati!",
                ImageUrl = "uploads/news/new_equipment.jpg",
                PublishedAtUtc = new DateTime(2026, 6, 10, 9, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new NewsItem
            {
                Id = 3,
                Title = "Uvodimo Boxing Fundamentals i Morning Run Club!",
                Content = "Od ovog mjeseca u ponudi su dva nova programa: Boxing Fundamentals za sve nivoe i Morning Run Club za ljubitelje trčanja. Rezervišite svoje mjesto već danas.",
                ImageUrl = "uploads/news/yoga_opening.jpg",
                PublishedAtUtc = new DateTime(2026, 6, 20, 9, 0, 0, DateTimeKind.Utc),
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
            },
            new RecommendationSignal
            {
                Id = 3,
                SignalType = RecommendationSignalType.ReservationCompleted,
                Weight = 1.0m,
                CreatedAtUtc = new DateTime(2026, 7, 5, 9, 5, 0, DateTimeKind.Utc),
                UserAccountId = 2,
                TrainingId = 3,
                TrainingCategoryId = 3,
                ReservationId = 3
            },
            new RecommendationSignal
            {
                Id = 4,
                SignalType = RecommendationSignalType.ReservationCompleted,
                Weight = 1.0m,
                CreatedAtUtc = new DateTime(2026, 6, 28, 9, 40, 0, DateTimeKind.Utc),
                UserAccountId = 6,
                TrainingId = 6,
                TrainingCategoryId = 1,
                ReservationId = 4
            },
            new RecommendationSignal
            {
                Id = 5,
                SignalType = RecommendationSignalType.ReservationCompleted,
                Weight = 1.0m,
                CreatedAtUtc = new DateTime(2026, 7, 2, 18, 50, 0, DateTimeKind.Utc),
                UserAccountId = 7,
                TrainingId = 5,
                TrainingCategoryId = 5,
                ReservationId = 5
            }
        );
    }
}