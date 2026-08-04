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
            new DifficultyLevel { Id = 1, Name = "Početni", SortOrder = 1, IsActive = true },
            new DifficultyLevel { Id = 2, Name = "Srednji", SortOrder = 2, IsActive = true },
            new DifficultyLevel { Id = 3, Name = "Napredni", SortOrder = 3, IsActive = true }
        );
    }

    private void SeedSpecializations(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Specialization>().HasData(
            new Specialization { Id = 1, Name = "Snaga i kondicija", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Specialization { Id = 2, Name = "Joga i pilates", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Specialization { Id = 3, Name = "Kardio i HIIT", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Specialization { Id = 4, Name = "CrossFit", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Specialization { Id = 5, Name = "Bodibilding", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Specialization { Id = 6, Name = "Funkcionalni trening", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Specialization { Id = 7, Name = "Boks i kickboks", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Specialization { Id = 8, Name = "Rehabilitacija i mobilnost", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Specialization { Id = 9, Name = "Plivanje i akva fitnes", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Specialization { Id = 10, Name = "Trening za seniore", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) }
        );
    }

    private void SeedHalls(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Hall>().HasData(
            new Hall { Id = 1, Name = "Glavna teretana", Capacity = 30, LocationDescription = "Prizemlje, Zona A", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Hall { Id = 2, Name = "Studio za jogu i pilates", Capacity = 15, LocationDescription = "Prvi sprat, Zona B", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Hall { Id = 3, Name = "Sala za spinning", Capacity = 20, LocationDescription = "Prvi sprat, Zona C", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Hall { Id = 4, Name = "Ring za borilačke sportove", Capacity = 16, LocationDescription = "Prizemlje, Zona D", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Hall { Id = 5, Name = "Funkcionalna zona", Capacity = 24, LocationDescription = "Prizemlje, Zona E", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Hall { Id = 6, Name = "Studio za pilates reformer", Capacity = 12, LocationDescription = "Drugi sprat, Zona A", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Hall { Id = 7, Name = "Vanjski teren", Capacity = 30, LocationDescription = "Dvorište iza objekta", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Hall { Id = 8, Name = "Sala za oporavak", Capacity = 10, LocationDescription = "Drugi sprat, Zona B", IsActive = false, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) }
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
                Username = "trainer",
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
            },
            new UserAccount
            {
                Id = 9,
                FirstName = "Nedim",
                LastName = "Karić",
                Email = "nedim@fitbook.com",
                PhoneNumber = "+38761555004",
                Username = "nedimkaric",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Trainer,
                ProfileImageUrl = "uploads/trainers/trainer1.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 10,
                FirstName = "Selma",
                LastName = "Dizdarević",
                Email = "selma@fitbook.com",
                PhoneNumber = "+38761555005",
                Username = "selmadizdarevic",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Trainer,
                ProfileImageUrl = "uploads/trainers/trainer2.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 11,
                FirstName = "Tarik",
                LastName = "Mujkić",
                Email = "tarik@fitbook.com",
                PhoneNumber = "+38761555006",
                Username = "tarikmujkic",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Trainer,
                ProfileImageUrl = "uploads/trainers/trainer3.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 12,
                FirstName = "Ivana",
                LastName = "Perić",
                Email = "ivana@fitbook.com",
                PhoneNumber = "+38761555007",
                Username = "ivanaperic",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Trainer,
                ProfileImageUrl = "uploads/trainers/trainer2.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 13,
                FirstName = "Haris",
                LastName = "Begić",
                Email = "haris@fitbook.com",
                PhoneNumber = "+38761555008",
                Username = "harisbegic",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.Trainer,
                ProfileImageUrl = "uploads/trainers/trainer1.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 14,
                FirstName = "Adnan",
                LastName = "Softić",
                Email = "adnan@fitbook.com",
                PhoneNumber = "+38761555013",
                Username = "adnan",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/john.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 8, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 15,
                FirstName = "Melisa",
                LastName = "Kovačević",
                Email = "melisa@fitbook.com",
                PhoneNumber = "+38761555014",
                Username = "melisa",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/jane.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 8, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 16,
                FirstName = "Damir",
                LastName = "Alispahić",
                Email = "damir@fitbook.com",
                PhoneNumber = "+38761555015",
                Username = "damir",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/guest.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 12, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 17,
                FirstName = "Azra",
                LastName = "Šehić",
                Email = "azra@fitbook.com",
                PhoneNumber = "+38761555016",
                Username = "azra",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/jane.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 12, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 18,
                FirstName = "Kenan",
                LastName = "Delić",
                Email = "kenan@fitbook.com",
                PhoneNumber = "+38761555017",
                Username = "kenan",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/john.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 18, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 19,
                FirstName = "Dženana",
                LastName = "Muratović",
                Email = "dzenana@fitbook.com",
                PhoneNumber = "+38761555018",
                Username = "dzenana",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/guest.jpg",
                IsActive = true,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 18, 0, 0, 0, DateTimeKind.Utc)
            },
            new UserAccount
            {
                Id = 20,
                FirstName = "Vedad",
                LastName = "Imamović",
                Email = "vedad@fitbook.com",
                PhoneNumber = "+38761555019",
                Username = "vedad",
                PasswordHash = SeedData.TestPasswordHash,
                Role = Roles.User,
                ProfileImageUrl = "uploads/users/john.jpg",
                IsActive = false,
                IsDeleted = false,
                CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc)
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
                Biography = "Certificirani trener sa preko 8 godina iskustva u atletskom treningu.",
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
                Biography = "Posvećena pomaganju ljudima da pronađu ravnotežu i fleksibilnost.",
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
                Biography = "Energični HIIT treninzi koji vas drže u sagorijevanju kalorija.",
                ImageUrl = "uploads/trainers/trainer3.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 5
            },
            new Trainer
            {
                Id = 4,
                FirstName = "Nedim",
                LastName = "Karić",
                SpecializationId = 6,
                Biography = "Specijalista za funkcionalni trening i pripremu sportista.",
                ImageUrl = "uploads/trainers/trainer1.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 9
            },
            new Trainer
            {
                Id = 5,
                FirstName = "Selma",
                LastName = "Dizdarević",
                SpecializationId = 8,
                Biography = "Fizioterapeut i trener mobilnosti, fokus na oporavak nakon povreda.",
                ImageUrl = "uploads/trainers/trainer2.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 10
            },
            new Trainer
            {
                Id = 6,
                FirstName = "Tarik",
                LastName = "Mujkić",
                SpecializationId = 7,
                Biography = "Bivši takmičar u boksu, vodi grupne i individualne treninge.",
                ImageUrl = "uploads/trainers/trainer3.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 11
            },
            new Trainer
            {
                Id = 7,
                FirstName = "Ivana",
                LastName = "Perić",
                SpecializationId = 2,
                Biography = "Instruktorica pilatesa na reformeru s certifikatom druge razine.",
                ImageUrl = "uploads/trainers/trainer2.jpg",
                IsAvailable = true,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 12
            },
            new Trainer
            {
                Id = 8,
                FirstName = "Haris",
                LastName = "Begić",
                SpecializationId = 5,
                Biography = "Trener bodibildinga, priprema klijente za takmičenja i transformacije.",
                ImageUrl = "uploads/trainers/trainer1.jpg",
                IsAvailable = false,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 2, 0, 0, 0, DateTimeKind.Utc),
                UserAccountId = 13
            }
        );
    }

    private void SeedTrainingCategories(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TrainingCategory>().HasData(
            new TrainingCategory { Id = 1, Name = "Kardio", Description = "Treninzi za poboljšanje zdravlja srca i izdržljivosti.", IsActive = true },
            new TrainingCategory { Id = 2, Name = "Snaga", Description = "Trening s opterećenjem za izgradnju mišićne mase.", IsActive = true },
            new TrainingCategory { Id = 3, Name = "Tijelo i um", Description = "Joga, istezanje i vježbe svjesnosti.", IsActive = true },
            new TrainingCategory { Id = 4, Name = "Oporavak i mobilnost", Description = "Lagani oporavak, istezanje i vježbe mobilnosti.", IsActive = true },
            new TrainingCategory { Id = 5, Name = "Borilački sportovi", Description = "Kondicija inspirisana boksom i borilačkim vještinama.", IsActive = true },
            new TrainingCategory { Id = 6, Name = "Funkcionalni trening", Description = "Pokreti iz svakodnevnog života uz vlastitu težinu i sprave.", IsActive = true },
            new TrainingCategory { Id = 7, Name = "Grupni fitnes", Description = "Energični grupni programi uz muziku i vodstvo trenera.", IsActive = true },
            new TrainingCategory { Id = 8, Name = "Personalni trening", Description = "Individualni rad s trenerom po mjeri korisnika.", IsActive = true }
        );
    }

    private void SeedTrainings(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Training>().HasData(
            new Training
            {
                Id = 1,
                Name = "HIIT Eksplozija",
                Description = "Intervalni trening visokog intenziteta za ubrzanje metabolizma.",
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
                Name = "Dizanje tegova",
                Description = "Naučite i izvodite pravilnu tehniku dizanja s tegovima.",
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
                Name = "Vinyasa joga",
                Description = "Tečne sekvence joga poza uz kontrolu disanja.",
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
                Name = "Opuštanje i mobilnost",
                Description = "Vođeno miofascijalno opuštanje i vježbe mobilnosti zglobova.",
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
                Name = "Osnove boksa",
                Description = "Rad nogu, kombinacije i rad na fokuserima za početnike i srednji nivo.",
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
                Name = "Jutarnji klub trčanja",
                Description = "Vođeni intervalni trening trčanja na otvorenom za početak dana.",
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
                Name = "Tehnika mrtvog dizanja",
                Description = "Radionica tehnike mrtvog dizanja za sigurno povećanje opterećenja.",
                DurationMinutes = 60,
                MaxParticipants = 8,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 2,
                DifficultyLevelId = 3
            },
            new Training
            {
                Id = 8,
                Name = "Spinning maraton",
                Description = "Grupni trening na sobnim biciklima uz muziku i intervalne uspone.",
                DurationMinutes = 45,
                MaxParticipants = 20,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 1,
                DifficultyLevelId = 2
            },
            new Training
            {
                Id = 9,
                Name = "Pilates reformer",
                Description = "Rad na reformeru za snagu dubokih mišića i stabilnost kičme.",
                DurationMinutes = 55,
                MaxParticipants = 12,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 3,
                DifficultyLevelId = 2
            },
            new Training
            {
                Id = 10,
                Name = "Funkcionalni krug",
                Description = "Kružni trening s vlastitom težinom, girjama i TRX trakama.",
                DurationMinutes = 50,
                MaxParticipants = 18,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 6,
                DifficultyLevelId = 2
            },
            new Training
            {
                Id = 11,
                Name = "Kickboks za početnike",
                Description = "Osnovni udarci nogama i rukama uz kondicioni dio treninga.",
                DurationMinutes = 55,
                MaxParticipants = 16,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 25, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 5,
                DifficultyLevelId = 1
            },
            new Training
            {
                Id = 12,
                Name = "Trbušnjaci i core",
                Description = "Kratak i intenzivan trening trbušnih i stabilizacijskih mišića.",
                DurationMinutes = 30,
                MaxParticipants = 22,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 25, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 7,
                DifficultyLevelId = 1
            },
            new Training
            {
                Id = 13,
                Name = "Zumba",
                Description = "Plesni grupni fitnes program na latino ritmove.",
                DurationMinutes = 50,
                MaxParticipants = 24,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 25, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 7,
                DifficultyLevelId = 1
            },
            new Training
            {
                Id = 14,
                Name = "Personalni trening 1 na 1",
                Description = "Individualni trening prilagođen ciljevima i nivou korisnika.",
                DurationMinutes = 60,
                MaxParticipants = 1,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 8,
                DifficultyLevelId = 2
            },
            new Training
            {
                Id = 15,
                Name = "Trening za seniore",
                Description = "Lagani program snage i ravnoteže prilagođen starijim članovima.",
                DurationMinutes = 40,
                MaxParticipants = 14,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 6,
                DifficultyLevelId = 1
            },
            new Training
            {
                Id = 16,
                Name = "Ljetni bootcamp na otvorenom",
                Description = "Sezonski kondicioni trening na vanjskom terenu.",
                DurationMinutes = 60,
                MaxParticipants = 26,
                IsActive = false,
                CreatedAtUtc = new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc),
                TrainingCategoryId = 6,
                DifficultyLevelId = 3
            }
        );
    }

    private void SeedEquipment(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Equipment>().HasData(
            new Equipment { Id = 1, Name = "Girja", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 2, Name = "Set tegova", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 3, Name = "Prostirka za jogu", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 4, Name = "Pjenasti valjak", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 5, Name = "Bokserske rukavice", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 6, Name = "Elastična guma za vježbanje", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 7, Name = "Medicinka", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 8, Name = "Vijača", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 9, Name = "TRX trake", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 10, Name = "Sobni bicikl", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 11, Name = "Step platforma", IsActive = true, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) },
            new Equipment { Id = 12, Name = "Bosu lopta", IsActive = false, CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc) }
        );
    }

    private void SeedTrainingEquipment(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TrainingEquipment>().HasData(
            new TrainingEquipment { Id = 1, EquipmentId = 1, IsRequired = true, Note = "Preporučeno 8kg-16kg", TrainingId = 1, CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 2, EquipmentId = 2, IsRequired = true, Note = "Pojasevi su dostupni u sali", TrainingId = 2, CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 3, EquipmentId = 3, IsRequired = false, Note = "Prostirke su dostupne u studiju ili ponesite svoju", TrainingId = 3, CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 4, EquipmentId = 4, IsRequired = true, Note = "Dostupno u studiju", TrainingId = 4, CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 5, EquipmentId = 5, IsRequired = true, Note = "Ponesite svoje ili iznajmite na recepciji", TrainingId = 5, CreatedAtUtc = new DateTime(2026, 1, 15, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 6, EquipmentId = 8, IsRequired = false, Note = "Koristi se u zagrijavanju", TrainingId = 1, CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 7, EquipmentId = 6, IsRequired = false, Note = "Za lakše varijante vježbi", TrainingId = 4, CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 8, EquipmentId = 10, IsRequired = true, Note = "Bicikl se dodjeljuje pri dolasku", TrainingId = 8, CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 9, EquipmentId = 3, IsRequired = true, Note = "Obavezna vlastita prostirka", TrainingId = 9, CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 10, EquipmentId = 9, IsRequired = true, Note = "TRX trake su montirane u funkcionalnoj zoni", TrainingId = 10, CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 11, EquipmentId = 1, IsRequired = false, Note = "Girje 8kg-24kg dostupne u zoni", TrainingId = 10, CreatedAtUtc = new DateTime(2026, 1, 20, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 12, EquipmentId = 5, IsRequired = true, Note = "Rukavice i štitnici za potkoljenice", TrainingId = 11, CreatedAtUtc = new DateTime(2026, 1, 25, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 13, EquipmentId = 3, IsRequired = true, Note = "Prostirka je obavezna", TrainingId = 12, CreatedAtUtc = new DateTime(2026, 1, 25, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 14, EquipmentId = 7, IsRequired = false, Note = "Medicinka 3kg-6kg", TrainingId = 12, CreatedAtUtc = new DateTime(2026, 1, 25, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 15, EquipmentId = 11, IsRequired = false, Note = "Step platforma za napredne koreografije", TrainingId = 13, CreatedAtUtc = new DateTime(2026, 1, 25, 0, 0, 0, DateTimeKind.Utc) },
            new TrainingEquipment { Id = 16, EquipmentId = 6, IsRequired = true, Note = "Lagane gume za vježbe ravnoteže", TrainingId = 15, CreatedAtUtc = new DateTime(2026, 2, 1, 0, 0, 0, DateTimeKind.Utc) }
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
            },
            new TrainingTerm
            {
                Id = 101,
                StartTimeUtc = new DateTime(2026, 7, 8, 9, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 8, 9, 45, 0, DateTimeKind.Utc),
                MaxParticipants = 20,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 8,
                TrainerId = 4,
                HallId = 3
            },
            new TrainingTerm
            {
                Id = 102,
                StartTimeUtc = new DateTime(2026, 7, 9, 17, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 9, 17, 55, 0, DateTimeKind.Utc),
                MaxParticipants = 12,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 9,
                TrainerId = 7,
                HallId = 6
            },
            new TrainingTerm
            {
                Id = 103,
                StartTimeUtc = new DateTime(2026, 7, 10, 18, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 10, 18, 50, 0, DateTimeKind.Utc),
                MaxParticipants = 18,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 10,
                TrainerId = 4,
                HallId = 5
            },
            new TrainingTerm
            {
                Id = 104,
                StartTimeUtc = new DateTime(2026, 7, 11, 19, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 11, 19, 55, 0, DateTimeKind.Utc),
                MaxParticipants = 16,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 7, 1, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 11,
                TrainerId = 6,
                HallId = 4
            },
            new TrainingTerm
            {
                Id = 105,
                StartTimeUtc = new DateTime(2026, 7, 14, 7, 30, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 14, 8, 0, 0, DateTimeKind.Utc),
                MaxParticipants = 22,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 7, 5, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 12,
                TrainerId = 5,
                HallId = 5
            },
            new TrainingTerm
            {
                Id = 106,
                StartTimeUtc = new DateTime(2026, 7, 15, 18, 30, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 15, 19, 20, 0, DateTimeKind.Utc),
                MaxParticipants = 15,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 7, 5, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 13,
                TrainerId = 7,
                HallId = 2
            },
            new TrainingTerm
            {
                Id = 107,
                StartTimeUtc = new DateTime(2026, 7, 16, 10, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 16, 11, 0, 0, DateTimeKind.Utc),
                MaxParticipants = 1,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 7, 5, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 14,
                TrainerId = 8,
                HallId = 1
            },
            new TrainingTerm
            {
                Id = 108,
                StartTimeUtc = new DateTime(2026, 7, 18, 9, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 18, 9, 40, 0, DateTimeKind.Utc),
                MaxParticipants = 14,
                Status = TrainingTermStatus.Completed,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 7, 10, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 15,
                TrainerId = 5,
                HallId = 5
            },
            new TrainingTerm
            {
                Id = 109,
                StartTimeUtc = new DateTime(2026, 7, 20, 8, 0, 0, DateTimeKind.Utc),
                EndTimeUtc = new DateTime(2026, 7, 20, 8, 45, 0, DateTimeKind.Utc),
                MaxParticipants = 20,
                Status = TrainingTermStatus.Cancelled,
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 7, 10, 0, 0, 0, DateTimeKind.Utc),
                TrainingId = 1,
                TrainerId = 4,
                HallId = 7
            }
        );
    }

    private void SeedMembershipPackages(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<MembershipPackage>().HasData(
            new MembershipPackage
            {
                Id = 1,
                Name = "Mjesečni Osnovni",
                DurationDays = 30,
                Price = 50.00m,
                SavingsAmount = 0.00m,
                IncludedBenefits = "Pristup glavnoj sali, 3 grupna treninga sedmično.",
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new MembershipPackage
            {
                Id = 2,
                Name = "Tromjesečni Premium",
                DurationDays = 90,
                Price = 120.00m,
                SavingsAmount = 30.00m,
                IncludedBenefits = "Neograničeni grupni treninzi, pristup sauni, 1 besplatan personalni trening.",
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new MembershipPackage
            {
                Id = 3,
                Name = "Godišnji VIP",
                DurationDays = 365,
                Price = 400.00m,
                SavingsAmount = 200.00m,
                IncludedBenefits = "Neograničeni grupni treninzi, pristup sauni, 4 besplatna personalna treninga, prioritetno rezervisanje.",
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new MembershipPackage
            {
                Id = 4,
                Name = "Sedmični Probni",
                DurationDays = 7,
                Price = 15.00m,
                SavingsAmount = 0.00m,
                IncludedBenefits = "Pristup glavnoj sali i 2 grupna treninga tokom sedmice.",
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new MembershipPackage
            {
                Id = 5,
                Name = "Polugodišnji Standard",
                DurationDays = 180,
                Price = 230.00m,
                SavingsAmount = 70.00m,
                IncludedBenefits = "Neograničeni grupni treninzi, pristup sauni, 2 besplatna personalna treninga.",
                IsActive = true,
                CreatedAtUtc = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc)
            },
            new MembershipPackage
            {
                Id = 6,
                Name = "Studentski Mjesečni",
                DurationDays = 30,
                Price = 35.00m,
                SavingsAmount = 15.00m,
                IncludedBenefits = "Pristup glavnoj sali i grupnim treninzima uz važeći indeks.",
                IsActive = false,
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
                Reason = "Automatski potvrđeno nakon uspješne uplate i provjere aktivne članarine",
                ReservationId = 1,
                ChangedByUserAccountId = 1
            },
            new ReservationStatusAudit
            {
                Id = 2,
                PreviousStatus = ReservationStatus.Confirmed,
                NewStatus = ReservationStatus.Completed,
                ChangedAtUtc = new DateTime(2026, 6, 25, 11, 0, 0, DateTimeKind.Utc),
                Reason = "Označeno kao završeno nakon završetka termina",
                ReservationId = 1,
                ChangedByUserAccountId = 5
            },
            new ReservationStatusAudit
            {
                Id = 3,
                PreviousStatus = ReservationStatus.Confirmed,
                NewStatus = ReservationStatus.Completed,
                ChangedAtUtc = new DateTime(2026, 7, 5, 9, 5, 0, DateTimeKind.Utc),
                Reason = "Označeno kao završeno nakon završetka termina",
                ReservationId = 3,
                ChangedByUserAccountId = 4
            },
            new ReservationStatusAudit
            {
                Id = 4,
                PreviousStatus = ReservationStatus.Confirmed,
                NewStatus = ReservationStatus.Completed,
                ChangedAtUtc = new DateTime(2026, 6, 28, 9, 40, 0, DateTimeKind.Utc),
                Reason = "Označeno kao završeno nakon završetka termina",
                ReservationId = 4,
                ChangedByUserAccountId = 5
            },
            new ReservationStatusAudit
            {
                Id = 5,
                PreviousStatus = ReservationStatus.Confirmed,
                NewStatus = ReservationStatus.Completed,
                ChangedAtUtc = new DateTime(2026, 7, 2, 18, 50, 0, DateTimeKind.Utc),
                Reason = "Označeno kao završeno nakon završetka termina",
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
                Title = "Rezervacija potvrđena",
                Content = "Vaša rezervacija za Vinyasa joga je uspješno potvrđena.",
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
                Content = "Vaš trening za Jutarnji klub trčanja je uspješno završen. Hvala na dolasku!",
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
                Content = "Vaš trening za Osnove boksa je uspješno završen. Hvala na dolasku!",
                IsRead = false,
                CreatedAtUtc = new DateTime(2026, 7, 2, 18, 50, 0, DateTimeKind.Utc),
                NotificationType = NotificationType.ReservationCompleted,
                UserAccountId = 7
            },
            new SystemNotification
            {
                Id = 7,
                Title = "Vaša rezervacija je otkazana",
                Content = "Vaša rezervacija za Jutarnji klub trčanja je otkazana. Razlog: Promjena rasporeda korisnika.",
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
                Title = "Veliko otvorenje našeg joga studija!",
                Content = "Sa zadovoljstvom objavljujemo da je naš novi premium studio za jogu i pilates na prvom spratu sada otvoren za rezervacije.",
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
                Title = "Uvodimo Osnove boksa i Jutarnji klub trčanja!",
                Content = "Od ovog mjeseca u ponudi su dva nova programa: Osnove boksa za sve nivoe i Jutarnji klub trčanja za ljubitelje trčanja. Rezervišite svoje mjesto već danas.",
                ImageUrl = "uploads/news/yoga_opening.jpg",
                PublishedAtUtc = new DateTime(2026, 6, 20, 9, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new NewsItem
            {
                Id = 4,
                Title = "Otvorena je nova funkcionalna zona",
                Content = "U prizemlju je uređena funkcionalna zona sa TRX trakama, girjama i prostorom za kružni trening. Zona je dostupna svim članovima bez dodatne naknade.",
                ImageUrl = "uploads/news/new_equipment.jpg",
                PublishedAtUtc = new DateTime(2026, 6, 28, 10, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new NewsItem
            {
                Id = 5,
                Title = "Pilates reformer stigao u FitBook",
                Content = "Novi studio na drugom spratu opremljen je reformerima. Termini su ograničeni na 12 mjesta, pa preporučujemo raniju rezervaciju.",
                ImageUrl = "uploads/news/yoga_opening.jpg",
                PublishedAtUtc = new DateTime(2026, 7, 3, 9, 30, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new NewsItem
            {
                Id = 6,
                Title = "Ljetni raspored termina",
                Content = "Tokom jula i augusta jutarnji termini počinju sat ranije zbog visokih temperatura. Provjerite ažurirani raspored u aplikaciji.",
                ImageUrl = "uploads/news/new_equipment.jpg",
                PublishedAtUtc = new DateTime(2026, 7, 6, 8, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new NewsItem
            {
                Id = 7,
                Title = "Novi trener za borilačke sportove",
                Content = "Tarik Mujkić, bivši takmičar u boksu, pridružio se našem timu i vodi programe Osnove boksa i Kickboks za početnike.",
                ImageUrl = "uploads/news/yoga_opening.jpg",
                PublishedAtUtc = new DateTime(2026, 7, 9, 11, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new NewsItem
            {
                Id = 8,
                Title = "Polugodišnji paket uz uštedu od 70 KM",
                Content = "Uveli smo Polugodišnji Standard paket koji donosi neograničene grupne treninge i dva besplatna personalna treninga.",
                ImageUrl = "uploads/news/new_equipment.jpg",
                PublishedAtUtc = new DateTime(2026, 7, 14, 12, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new NewsItem
            {
                Id = 9,
                Title = "Program treninga za seniore",
                Content = "Pokrenuli smo program prilagođen starijim članovima, s naglaskom na ravnotežu, mobilnost i laganu snagu. Termini su dva puta sedmično.",
                ImageUrl = "uploads/news/yoga_opening.jpg",
                PublishedAtUtc = new DateTime(2026, 7, 19, 9, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new NewsItem
            {
                Id = 10,
                Title = "Radovi na sali za oporavak",
                Content = "Sala za oporavak je privremeno zatvorena zbog radova na instalacijama. O ponovnom otvaranju obavijestit ćemo vas kroz aplikaciju.",
                ImageUrl = "uploads/news/new_equipment.jpg",
                PublishedAtUtc = new DateTime(2026, 7, 25, 15, 0, 0, DateTimeKind.Utc),
                IsActive = false
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