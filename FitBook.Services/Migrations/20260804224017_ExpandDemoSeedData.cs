using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class ExpandDemoSeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Equipment",
                columns: new[] { "Id", "CreatedAtUtc", "IsActive", "Name", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 6, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Elastična guma za vježbanje", null },
                    { 7, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Medicinka", null },
                    { 8, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Vijača", null },
                    { 9, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "TRX trake", null },
                    { 10, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Sobni bicikl", null },
                    { 11, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Step platforma", null },
                    { 12, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), false, "Bosu lopta", null }
                });

            migrationBuilder.InsertData(
                table: "Halls",
                columns: new[] { "Id", "Capacity", "CreatedAtUtc", "IsActive", "LocationDescription", "Name", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 4, 16, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Prizemlje, Zona D", "Ring za borilačke sportove", null },
                    { 5, 24, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Prizemlje, Zona E", "Funkcionalna zona", null },
                    { 6, 12, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Drugi sprat, Zona A", "Studio za pilates reformer", null },
                    { 7, 30, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Dvorište iza objekta", "Vanjski teren", null },
                    { 8, 10, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), false, "Drugi sprat, Zona B", "Sala za oporavak", null }
                });

            migrationBuilder.InsertData(
                table: "MembershipPackages",
                columns: new[] { "Id", "CreatedAtUtc", "DurationDays", "IncludedBenefits", "IsActive", "IsDeleted", "Name", "Price", "SavingsAmount", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 4, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 7, "Pristup glavnoj sali i 2 grupna treninga tokom sedmice.", true, false, "Sedmični Probni", 15.00m, 0.00m, null },
                    { 5, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 180, "Neograničeni grupni treninzi, pristup sauni, 2 besplatna personalna treninga.", true, false, "Polugodišnji Standard", 230.00m, 70.00m, null },
                    { 6, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 30, "Pristup glavnoj sali i grupnim treninzima uz važeći indeks.", false, false, "Studentski Mjesečni", 35.00m, 15.00m, null }
                });

            migrationBuilder.InsertData(
                table: "NewsItems",
                columns: new[] { "Id", "Content", "CreatedAtUtc", "ImageUrl", "IsActive", "PublishedAtUtc", "Title", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 4, "U prizemlju je uređena funkcionalna zona sa TRX trakama, girjama i prostorom za kružni trening. Zona je dostupna svim članovima bez dodatne naknade.", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/new_equipment.jpg", true, new DateTime(2026, 6, 28, 10, 0, 0, 0, DateTimeKind.Utc), "Otvorena je nova funkcionalna zona", null },
                    { 5, "Novi studio na drugom spratu opremljen je reformerima. Termini su ograničeni na 12 mjesta, pa preporučujemo raniju rezervaciju.", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/yoga_opening.jpg", true, new DateTime(2026, 7, 3, 9, 30, 0, 0, DateTimeKind.Utc), "Pilates reformer stigao u FitBook", null },
                    { 6, "Tokom jula i augusta jutarnji termini počinju sat ranije zbog visokih temperatura. Provjerite ažurirani raspored u aplikaciji.", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/new_equipment.jpg", true, new DateTime(2026, 7, 6, 8, 0, 0, 0, DateTimeKind.Utc), "Ljetni raspored termina", null },
                    { 7, "Tarik Mujkić, bivši takmičar u boksu, pridružio se našem timu i vodi programe Osnove boksa i Kickboks za početnike.", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/yoga_opening.jpg", true, new DateTime(2026, 7, 9, 11, 0, 0, 0, DateTimeKind.Utc), "Novi trener za borilačke sportove", null },
                    { 8, "Uveli smo Polugodišnji Standard paket koji donosi neograničene grupne treninge i dva besplatna personalna treninga.", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/new_equipment.jpg", true, new DateTime(2026, 7, 14, 12, 0, 0, 0, DateTimeKind.Utc), "Polugodišnji paket uz uštedu od 70 KM", null },
                    { 9, "Pokrenuli smo program prilagođen starijim članovima, s naglaskom na ravnotežu, mobilnost i laganu snagu. Termini su dva puta sedmično.", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/yoga_opening.jpg", true, new DateTime(2026, 7, 19, 9, 0, 0, 0, DateTimeKind.Utc), "Program treninga za seniore", null },
                    { 10, "Sala za oporavak je privremeno zatvorena zbog radova na instalacijama. O ponovnom otvaranju obavijestit ćemo vas kroz aplikaciju.", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/new_equipment.jpg", false, new DateTime(2026, 7, 25, 15, 0, 0, 0, DateTimeKind.Utc), "Radovi na sali za oporavak", null }
                });

            migrationBuilder.InsertData(
                table: "Specializations",
                columns: new[] { "Id", "CreatedAtUtc", "IsActive", "Name", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 6, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Funkcionalni trening", null },
                    { 7, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Boks i kickboks", null },
                    { 8, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Rehabilitacija i mobilnost", null },
                    { 9, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Plivanje i akva fitnes", null },
                    { 10, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, "Trening za seniore", null }
                });

            migrationBuilder.InsertData(
                table: "TrainingCategories",
                columns: new[] { "Id", "CreatedAtUtc", "Description", "IsActive", "Name", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 6, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Pokreti iz svakodnevnog života uz vlastitu težinu i sprave.", true, "Funkcionalni trening", null },
                    { 7, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Energični grupni programi uz muziku i vodstvo trenera.", true, "Grupni fitnes", null },
                    { 8, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Individualni rad s trenerom po mjeri korisnika.", true, "Personalni trening", null }
                });

            migrationBuilder.InsertData(
                table: "Trainings",
                columns: new[] { "Id", "CreatedAtUtc", "Description", "DifficultyLevelId", "DurationMinutes", "IsActive", "MaxParticipants", "Name", "TrainingCategoryId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 8, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), "Grupni trening na sobnim biciklima uz muziku i intervalne uspone.", 2, 45, true, 20, "Spinning maraton", 1, null },
                    { 9, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), "Rad na reformeru za snagu dubokih mišića i stabilnost kičme.", 2, 55, true, 12, "Pilates reformer", 3, null },
                    { 11, new DateTime(2026, 1, 25, 0, 0, 0, 0, DateTimeKind.Utc), "Osnovni udarci nogama i rukama uz kondicioni dio treninga.", 1, 55, true, 16, "Kickboks za početnike", 5, null }
                });

            migrationBuilder.InsertData(
                table: "UserAccounts",
                columns: new[] { "Id", "CreatedAtUtc", "Email", "FirstName", "IsActive", "IsDeleted", "LastName", "PasswordHash", "PhoneNumber", "ProfileImageUrl", "Role", "UpdatedAtUtc", "Username" },
                values: new object[,]
                {
                    { 9, new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "nedim@fitbook.com", "Nedim", true, false, "Karić", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555004", "uploads/trainers/trainer1.jpg", "Trainer", null, "nedimkaric" },
                    { 10, new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "selma@fitbook.com", "Selma", true, false, "Dizdarević", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555005", "uploads/trainers/trainer2.jpg", "Trainer", null, "selmadizdarevic" },
                    { 11, new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "tarik@fitbook.com", "Tarik", true, false, "Mujkić", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555006", "uploads/trainers/trainer3.jpg", "Trainer", null, "tarikmujkic" },
                    { 12, new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "ivana@fitbook.com", "Ivana", true, false, "Perić", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555007", "uploads/trainers/trainer2.jpg", "Trainer", null, "ivanaperic" },
                    { 13, new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "haris@fitbook.com", "Haris", true, false, "Begić", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555008", "uploads/trainers/trainer1.jpg", "Trainer", null, "harisbegic" },
                    { 14, new DateTime(2026, 1, 8, 0, 0, 0, 0, DateTimeKind.Utc), "adnan@fitbook.com", "Adnan", true, false, "Softić", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555013", "uploads/users/john.jpg", "User", null, "adnan" },
                    { 15, new DateTime(2026, 1, 8, 0, 0, 0, 0, DateTimeKind.Utc), "melisa@fitbook.com", "Melisa", true, false, "Kovačević", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555014", "uploads/users/jane.jpg", "User", null, "melisa" },
                    { 16, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), "damir@fitbook.com", "Damir", true, false, "Alispahić", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555015", "uploads/users/guest.jpg", "User", null, "damir" },
                    { 17, new DateTime(2026, 1, 12, 0, 0, 0, 0, DateTimeKind.Utc), "azra@fitbook.com", "Azra", true, false, "Šehić", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555016", "uploads/users/jane.jpg", "User", null, "azra" },
                    { 18, new DateTime(2026, 1, 18, 0, 0, 0, 0, DateTimeKind.Utc), "kenan@fitbook.com", "Kenan", true, false, "Delić", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555017", "uploads/users/john.jpg", "User", null, "kenan" },
                    { 19, new DateTime(2026, 1, 18, 0, 0, 0, 0, DateTimeKind.Utc), "dzenana@fitbook.com", "Dženana", true, false, "Muratović", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555018", "uploads/users/guest.jpg", "User", null, "dzenana" },
                    { 20, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), "vedad@fitbook.com", "Vedad", false, false, "Imamović", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555019", "uploads/users/john.jpg", "User", null, "vedad" }
                });

            migrationBuilder.InsertData(
                table: "Trainers",
                columns: new[] { "Id", "Biography", "CreatedAtUtc", "FirstName", "ImageUrl", "IsActive", "IsAvailable", "LastName", "SpecializationId", "UpdatedAtUtc", "UserAccountId" },
                values: new object[,]
                {
                    { 4, "Specijalista za funkcionalni trening i pripremu sportista.", new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "Nedim", "uploads/trainers/trainer1.jpg", true, true, "Karić", 6, null, 9 },
                    { 5, "Fizioterapeut i trener mobilnosti, fokus na oporavak nakon povreda.", new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "Selma", "uploads/trainers/trainer2.jpg", true, true, "Dizdarević", 8, null, 10 },
                    { 6, "Bivši takmičar u boksu, vodi grupne i individualne treninge.", new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "Tarik", "uploads/trainers/trainer3.jpg", true, true, "Mujkić", 7, null, 11 },
                    { 7, "Instruktorica pilatesa na reformeru s certifikatom druge razine.", new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "Ivana", "uploads/trainers/trainer2.jpg", true, true, "Perić", 2, null, 12 },
                    { 8, "Trener bodibildinga, priprema klijente za takmičenja i transformacije.", new DateTime(2026, 1, 2, 0, 0, 0, 0, DateTimeKind.Utc), "Haris", "uploads/trainers/trainer1.jpg", true, false, "Begić", 5, null, 13 }
                });

            migrationBuilder.InsertData(
                table: "TrainingEquipment",
                columns: new[] { "Id", "CreatedAtUtc", "EquipmentId", "IsRequired", "Note", "TrainingId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 6, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), 8, false, "Koristi se u zagrijavanju", 1, null },
                    { 7, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), 6, false, "Za lakše varijante vježbi", 4, null },
                    { 8, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, "Bicikl se dodjeljuje pri dolasku", 8, null },
                    { 9, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), 3, true, "Obavezna vlastita prostirka", 9, null },
                    { 12, new DateTime(2026, 1, 25, 0, 0, 0, 0, DateTimeKind.Utc), 5, true, "Rukavice i štitnici za potkoljenice", 11, null }
                });

            migrationBuilder.InsertData(
                table: "Trainings",
                columns: new[] { "Id", "CreatedAtUtc", "Description", "DifficultyLevelId", "DurationMinutes", "IsActive", "MaxParticipants", "Name", "TrainingCategoryId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 10, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), "Kružni trening s vlastitom težinom, girjama i TRX trakama.", 2, 50, true, 18, "Funkcionalni krug", 6, null },
                    { 12, new DateTime(2026, 1, 25, 0, 0, 0, 0, DateTimeKind.Utc), "Kratak i intenzivan trening trbušnih i stabilizacijskih mišića.", 1, 30, true, 22, "Trbušnjaci i core", 7, null },
                    { 13, new DateTime(2026, 1, 25, 0, 0, 0, 0, DateTimeKind.Utc), "Plesni grupni fitnes program na latino ritmove.", 1, 50, true, 24, "Zumba", 7, null },
                    { 14, new DateTime(2026, 2, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Individualni trening prilagođen ciljevima i nivou korisnika.", 2, 60, true, 1, "Personalni trening 1 na 1", 8, null },
                    { 15, new DateTime(2026, 2, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Lagani program snage i ravnoteže prilagođen starijim članovima.", 1, 40, true, 14, "Trening za seniore", 6, null },
                    { 16, new DateTime(2026, 2, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Sezonski kondicioni trening na vanjskom terenu.", 3, 60, false, 26, "Ljetni bootcamp na otvorenom", 6, null }
                });

            migrationBuilder.InsertData(
                table: "TrainingEquipment",
                columns: new[] { "Id", "CreatedAtUtc", "EquipmentId", "IsRequired", "Note", "TrainingId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 10, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), 9, true, "TRX trake su montirane u funkcionalnoj zoni", 10, null },
                    { 11, new DateTime(2026, 1, 20, 0, 0, 0, 0, DateTimeKind.Utc), 1, false, "Girje 8kg-24kg dostupne u zoni", 10, null },
                    { 13, new DateTime(2026, 1, 25, 0, 0, 0, 0, DateTimeKind.Utc), 3, true, "Prostirka je obavezna", 12, null },
                    { 14, new DateTime(2026, 1, 25, 0, 0, 0, 0, DateTimeKind.Utc), 7, false, "Medicinka 3kg-6kg", 12, null },
                    { 15, new DateTime(2026, 1, 25, 0, 0, 0, 0, DateTimeKind.Utc), 11, false, "Step platforma za napredne koreografije", 13, null },
                    { 16, new DateTime(2026, 2, 1, 0, 0, 0, 0, DateTimeKind.Utc), 6, true, "Lagane gume za vježbe ravnoteže", 15, null }
                });

            migrationBuilder.InsertData(
                table: "TrainingTerms",
                columns: new[] { "Id", "CreatedAtUtc", "EndTimeUtc", "HallId", "IsActive", "MaxParticipants", "StartTimeUtc", "Status", "TrainerId", "TrainerReminderSentAtUtc", "TrainingId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 101, new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 8, 9, 45, 0, 0, DateTimeKind.Utc), 3, true, 20, new DateTime(2026, 7, 8, 9, 0, 0, 0, DateTimeKind.Utc), 3, 4, null, 8, null },
                    { 102, new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 9, 17, 55, 0, 0, DateTimeKind.Utc), 6, true, 12, new DateTime(2026, 7, 9, 17, 0, 0, 0, DateTimeKind.Utc), 3, 7, null, 9, null },
                    { 103, new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 10, 18, 50, 0, 0, DateTimeKind.Utc), 5, true, 18, new DateTime(2026, 7, 10, 18, 0, 0, 0, DateTimeKind.Utc), 3, 4, null, 10, null },
                    { 104, new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 11, 19, 55, 0, 0, DateTimeKind.Utc), 4, true, 16, new DateTime(2026, 7, 11, 19, 0, 0, 0, DateTimeKind.Utc), 3, 6, null, 11, null },
                    { 105, new DateTime(2026, 7, 5, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 14, 8, 0, 0, 0, DateTimeKind.Utc), 5, true, 22, new DateTime(2026, 7, 14, 7, 30, 0, 0, DateTimeKind.Utc), 3, 5, null, 12, null },
                    { 106, new DateTime(2026, 7, 5, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 15, 19, 20, 0, 0, DateTimeKind.Utc), 2, true, 15, new DateTime(2026, 7, 15, 18, 30, 0, 0, DateTimeKind.Utc), 3, 7, null, 13, null },
                    { 107, new DateTime(2026, 7, 5, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 16, 11, 0, 0, 0, DateTimeKind.Utc), 1, true, 1, new DateTime(2026, 7, 16, 10, 0, 0, 0, DateTimeKind.Utc), 3, 8, null, 14, null },
                    { 108, new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 18, 9, 40, 0, 0, DateTimeKind.Utc), 5, true, 14, new DateTime(2026, 7, 18, 9, 0, 0, 0, DateTimeKind.Utc), 3, 5, null, 15, null },
                    { 109, new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 20, 8, 45, 0, 0, DateTimeKind.Utc), 7, true, 20, new DateTime(2026, 7, 20, 8, 0, 0, 0, DateTimeKind.Utc), 2, 4, null, 1, null }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 101);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 102);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 103);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 104);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 105);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 106);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 107);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 108);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 109);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Equipment",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Trainers",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Specializations",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 13);
        }
    }
}
