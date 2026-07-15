using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class ExpandSeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "MembershipPackages",
                columns: new[] { "Id", "CreatedAtUtc", "DurationDays", "IncludedBenefits", "IsActive", "IsDeleted", "Name", "Price", "SavingsAmount", "UpdatedAtUtc" },
                values: new object[] { 3, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 365, "Unlimited group trainings, sauna access, 4 free personal sessions, priority booking.", true, false, "1 Year VIP", 400.00m, 200.00m, null });

            migrationBuilder.InsertData(
                table: "NewsItems",
                columns: new[] { "Id", "Content", "CreatedAtUtc", "ImageUrl", "IsActive", "PublishedAtUtc", "Title", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 2, "Prošireni smo novim setovima utega i spravama za trening snage u glavnoj dvorani. Dođite isprobati!", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/new_equipment.jpg", true, new DateTime(2026, 6, 10, 9, 0, 0, 0, DateTimeKind.Utc), "Nova oprema za snagu je stigla!", null },
                    { 3, "Od ovog mjeseca u ponudi su dva nova programa: Boxing Fundamentals za sve nivoe i Morning Run Club za ljubitelje trčanja. Rezervišite svoje mjesto već danas.", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/yoga_opening.jpg", true, new DateTime(2026, 6, 20, 9, 0, 0, 0, DateTimeKind.Utc), "Uvodimo Boxing Fundamentals i Morning Run Club!", null }
                });

            migrationBuilder.InsertData(
                table: "RecommendationSignals",
                columns: new[] { "Id", "CreatedAtUtc", "ReservationId", "SignalType", "TrainingCategoryId", "TrainingId", "UpdatedAtUtc", "UserAccountId", "Weight" },
                values: new object[] { 3, new DateTime(2026, 7, 5, 9, 5, 0, 0, DateTimeKind.Utc), 3, 4, 3, 3, null, 2, 1.0m });

            migrationBuilder.InsertData(
                table: "ReservationStatusAudits",
                columns: new[] { "Id", "ChangedAtUtc", "ChangedByUserAccountId", "CreatedAtUtc", "NewStatus", "PreviousStatus", "Reason", "ReservationId", "UpdatedAtUtc" },
                values: new object[] { 3, new DateTime(2026, 7, 5, 9, 5, 0, 0, DateTimeKind.Utc), 4, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 2, "Marked as completed after class finish", 3, null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CompletedAtUtc", "Status" },
                values: new object[] { new DateTime(2026, 7, 5, 9, 5, 0, 0, DateTimeKind.Utc), 4 });

            migrationBuilder.InsertData(
                table: "SystemNotifications",
                columns: new[] { "Id", "Content", "CreatedAtUtc", "IsRead", "NotificationType", "ReadAtUtc", "Title", "UpdatedAtUtc", "UserAccountId" },
                values: new object[] { 2, "Vaša članarina je uspješno plaćena i sada je aktivna.", new DateTime(2026, 5, 30, 10, 5, 0, 0, DateTimeKind.Utc), true, 5, new DateTime(2026, 5, 30, 11, 0, 0, 0, DateTimeKind.Utc), "Plaćanje članarine uspješno", null, 2 });

            migrationBuilder.InsertData(
                table: "TrainingCategories",
                columns: new[] { "Id", "CreatedAtUtc", "Description", "IsActive", "Name", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 4, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Low-impact recovery, stretching, and mobility work.", true, "Recovery & Mobility", null },
                    { 5, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Boxing and martial-arts inspired conditioning.", true, "Combat Sports", null }
                });

            migrationBuilder.UpdateData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 3,
                column: "Status",
                value: 3);

            migrationBuilder.InsertData(
                table: "Trainings",
                columns: new[] { "Id", "CreatedAtUtc", "Description", "DifficultyLevelId", "DurationMinutes", "IsActive", "MaxParticipants", "Name", "TrainingCategoryId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 6, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Coached outdoor interval running session to start the day.", 1, 40, true, 25, "Morning Run Club", 1, null },
                    { 7, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Barbell deadlift form clinic for lifters ready to add weight safely.", 3, 60, true, 8, "Deadlift Technique", 2, null }
                });

            migrationBuilder.InsertData(
                table: "UserAccounts",
                columns: new[] { "Id", "CreatedAtUtc", "Email", "FirstName", "IsActive", "IsDeleted", "LastName", "PasswordHash", "PhoneNumber", "ProfileImageUrl", "Role", "UpdatedAtUtc", "Username" },
                values: new object[,]
                {
                    { 6, new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), "amina@fitbook.com", "Amina", true, false, "Hodžić", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555010", "uploads/users/guest.jpg", "User", null, "amina" },
                    { 7, new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), "emir@fitbook.com", "Emir", true, false, "Halilović", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555011", "uploads/users/john.jpg", "User", null, "emir" },
                    { 8, new DateTime(2026, 1, 5, 0, 0, 0, 0, DateTimeKind.Utc), "lejla@fitbook.com", "Lejla", true, false, "Bećirović", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555012", "uploads/users/jane.jpg", "User", null, "lejla" }
                });

            migrationBuilder.InsertData(
                table: "SystemNotifications",
                columns: new[] { "Id", "Content", "CreatedAtUtc", "IsRead", "NotificationType", "ReadAtUtc", "Title", "UpdatedAtUtc", "UserAccountId" },
                values: new object[,]
                {
                    { 3, "Vaša članarina je istekla.", new DateTime(2026, 5, 1, 0, 5, 0, 0, DateTimeKind.Utc), false, 9, null, "Članarina je istekla", null, 6 },
                    { 4, "Vaša članarina je otkazana. Izvršen je povrat sredstava.", new DateTime(2026, 6, 1, 12, 0, 0, 0, DateTimeKind.Utc), false, 8, null, "Članarina je otkazana", null, 7 },
                    { 5, "Vaš trening za Morning Run Club je uspješno završen. Hvala na dolasku!", new DateTime(2026, 6, 28, 9, 40, 0, 0, DateTimeKind.Utc), true, 4, new DateTime(2026, 6, 28, 12, 0, 0, 0, DateTimeKind.Utc), "Trening je završen", null, 6 },
                    { 6, "Vaš trening za Boxing Fundamentals je uspješno završen. Hvala na dolasku!", new DateTime(2026, 7, 2, 18, 50, 0, 0, DateTimeKind.Utc), false, 4, null, "Trening je završen", null, 7 },
                    { 7, "Vaša rezervacija za Morning Run Club je otkazana. Razlog: Promjena rasporeda korisnika.", new DateTime(2026, 6, 27, 9, 0, 0, 0, DateTimeKind.Utc), false, 3, null, "Vaša rezervacija je otkazana", null, 8 }
                });

            migrationBuilder.InsertData(
                table: "TrainingTerms",
                columns: new[] { "Id", "CreatedAtUtc", "EndTimeUtc", "HallId", "IsActive", "MaxParticipants", "StartTimeUtc", "Status", "TrainerId", "TrainingId", "UpdatedAtUtc" },
                values: new object[] { 4, new DateTime(2026, 6, 21, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 6, 28, 9, 40, 0, 0, DateTimeKind.Utc), 1, true, 25, new DateTime(2026, 6, 28, 9, 0, 0, 0, DateTimeKind.Utc), 3, 3, 6, null });

            migrationBuilder.InsertData(
                table: "Trainings",
                columns: new[] { "Id", "CreatedAtUtc", "Description", "DifficultyLevelId", "DurationMinutes", "IsActive", "MaxParticipants", "Name", "TrainingCategoryId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 4, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Guided self-myofascial release and joint mobility drills.", 1, 30, true, 12, "Foam Rolling & Mobility", 4, null },
                    { 5, new DateTime(2026, 1, 15, 0, 0, 0, 0, DateTimeKind.Utc), "Footwork, combinations, and pad work for beginners and intermediates.", 2, 50, true, 14, "Boxing Fundamentals", 5, null }
                });

            migrationBuilder.InsertData(
                table: "UserMemberships",
                columns: new[] { "Id", "CreatedAtUtc", "EndDateUtc", "IsActive", "IsDeleted", "MembershipPackageId", "NextPaymentDateUtc", "StartDateUtc", "Status", "UpdatedAtUtc", "UserAccountId" },
                values: new object[,]
                {
                    { 2, new DateTime(2026, 3, 30, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 5, 1, 0, 0, 0, 0, DateTimeKind.Utc), false, false, 1, null, new DateTime(2026, 4, 1, 0, 0, 0, 0, DateTimeKind.Utc), 3, null, 6 },
                    { 3, new DateTime(2026, 4, 28, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 6, 1, 0, 0, 0, 0, DateTimeKind.Utc), false, false, 2, null, new DateTime(2026, 5, 1, 0, 0, 0, 0, DateTimeKind.Utc), 4, null, 7 },
                    { 4, new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Utc), false, false, 3, null, new DateTime(2026, 7, 10, 0, 0, 0, 0, DateTimeKind.Utc), 1, null, 8 }
                });

            migrationBuilder.InsertData(
                table: "MembershipPayments",
                columns: new[] { "Id", "Amount", "CreatedAtUtc", "Currency", "PaidAtUtc", "PaymentIntentId", "PaymentProvider", "RefundAmount", "RefundedAtUtc", "Status", "TransactionReference", "UpdatedAtUtc", "UserAccountId", "UserMembershipId" },
                values: new object[] { 2, 120.00m, new DateTime(2026, 5, 1, 9, 0, 0, 0, DateTimeKind.Utc), "USD", new DateTime(2026, 5, 1, 9, 5, 0, 0, DateTimeKind.Utc), "pi_seed_0000000002", "Stripe", 120.00m, new DateTime(2026, 6, 1, 12, 0, 0, 0, DateTimeKind.Utc), 4, "tx_998878", null, 7, 3 });

            migrationBuilder.InsertData(
                table: "Reservations",
                columns: new[] { "Id", "CancellationReason", "CancelledAtUtc", "CompletedAtUtc", "ConfirmedAtUtc", "CreatedAtUtc", "LastStatusChangedByUserAccountId", "ReminderSentAtUtc", "ReservedAtUtc", "Status", "TrainingTermId", "UpdatedAtUtc", "UserAccountId" },
                values: new object[,]
                {
                    { 4, null, null, new DateTime(2026, 6, 28, 9, 40, 0, 0, DateTimeKind.Utc), new DateTime(2026, 6, 27, 8, 10, 0, 0, DateTimeKind.Utc), new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, new DateTime(2026, 6, 27, 8, 0, 0, 0, DateTimeKind.Utc), 4, 4, null, 6 },
                    { 6, "Promjena rasporeda korisnika.", new DateTime(2026, 6, 27, 9, 0, 0, 0, DateTimeKind.Utc), null, null, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, new DateTime(2026, 6, 26, 14, 0, 0, 0, DateTimeKind.Utc), 3, 4, null, 8 }
                });

            migrationBuilder.InsertData(
                table: "TrainingEquipment",
                columns: new[] { "Id", "CreatedAtUtc", "IsRequired", "Name", "Note", "TrainingId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 4, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Foam Roller", "Provided in studio", 4, null },
                    { 5, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Boxing Gloves", "Bring your own or rent at front desk", 5, null }
                });

            migrationBuilder.InsertData(
                table: "TrainingTerms",
                columns: new[] { "Id", "CreatedAtUtc", "EndTimeUtc", "HallId", "IsActive", "MaxParticipants", "StartTimeUtc", "Status", "TrainerId", "TrainingId", "UpdatedAtUtc" },
                values: new object[] { 5, new DateTime(2026, 6, 25, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 2, 18, 50, 0, 0, DateTimeKind.Utc), 1, true, 14, new DateTime(2026, 7, 2, 18, 0, 0, 0, DateTimeKind.Utc), 3, 1, 5, null });

            migrationBuilder.InsertData(
                table: "RecommendationSignals",
                columns: new[] { "Id", "CreatedAtUtc", "ReservationId", "SignalType", "TrainingCategoryId", "TrainingId", "UpdatedAtUtc", "UserAccountId", "Weight" },
                values: new object[] { 4, new DateTime(2026, 6, 28, 9, 40, 0, 0, DateTimeKind.Utc), 4, 4, 1, 6, null, 6, 1.0m });

            migrationBuilder.InsertData(
                table: "ReservationStatusAudits",
                columns: new[] { "Id", "ChangedAtUtc", "ChangedByUserAccountId", "CreatedAtUtc", "NewStatus", "PreviousStatus", "Reason", "ReservationId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 4, new DateTime(2026, 6, 28, 9, 40, 0, 0, DateTimeKind.Utc), 5, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 2, "Marked as completed after class finish", 4, null },
                    { 6, new DateTime(2026, 6, 27, 9, 0, 0, 0, DateTimeKind.Utc), 8, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 1, "Promjena rasporeda korisnika.", 6, null }
                });

            migrationBuilder.InsertData(
                table: "Reservations",
                columns: new[] { "Id", "CancellationReason", "CancelledAtUtc", "CompletedAtUtc", "ConfirmedAtUtc", "CreatedAtUtc", "LastStatusChangedByUserAccountId", "ReminderSentAtUtc", "ReservedAtUtc", "Status", "TrainingTermId", "UpdatedAtUtc", "UserAccountId" },
                values: new object[] { 5, null, null, new DateTime(2026, 7, 2, 18, 50, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 1, 12, 5, 0, 0, DateTimeKind.Utc), new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, null, new DateTime(2026, 7, 1, 12, 0, 0, 0, DateTimeKind.Utc), 4, 5, null, 7 });

            migrationBuilder.InsertData(
                table: "RecommendationSignals",
                columns: new[] { "Id", "CreatedAtUtc", "ReservationId", "SignalType", "TrainingCategoryId", "TrainingId", "UpdatedAtUtc", "UserAccountId", "Weight" },
                values: new object[] { 5, new DateTime(2026, 7, 2, 18, 50, 0, 0, DateTimeKind.Utc), 5, 4, 5, 5, null, 7, 1.0m });

            migrationBuilder.InsertData(
                table: "ReservationStatusAudits",
                columns: new[] { "Id", "ChangedAtUtc", "ChangedByUserAccountId", "CreatedAtUtc", "NewStatus", "PreviousStatus", "Reason", "ReservationId", "UpdatedAtUtc" },
                values: new object[] { 5, new DateTime(2026, 7, 2, 18, 50, 0, 0, DateTimeKind.Utc), 3, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 2, "Marked as completed after class finish", 5, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "MembershipPayments",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "RecommendationSignals",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "RecommendationSignals",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "RecommendationSignals",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "UserMemberships",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "UserMemberships",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "UserMemberships",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Trainings",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CompletedAtUtc", "Status" },
                values: new object[] { null, 2 });

            migrationBuilder.UpdateData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 3,
                column: "Status",
                value: 1);
        }
    }
}
