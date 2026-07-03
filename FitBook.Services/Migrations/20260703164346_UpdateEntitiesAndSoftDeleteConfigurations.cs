using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateEntitiesAndSoftDeleteConfigurations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_UserAccounts_Email",
                table: "UserAccounts");

            migrationBuilder.DropIndex(
                name: "IX_UserAccounts_Username",
                table: "UserAccounts");

            migrationBuilder.DropIndex(
                name: "IX_MembershipPackages_Name",
                table: "MembershipPackages");

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "UserMemberships",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "TrainingEquipment",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "TrainingEquipment",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "TrainingCategories",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "TrainingCategories",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "SystemNotifications",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "ReservationStatusAudits",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "ReservationStatusAudits",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "Reservations",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "Reservations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "RecommendationSignals",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "NewsItems",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "NewsItems",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "MembershipPayments",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "MembershipPackages",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "Halls",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "Halls",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAtUtc",
                table: "DifficultyLevels",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAtUtc",
                table: "DifficultyLevels",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "DifficultyLevels",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "DifficultyLevels",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "DifficultyLevels",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Halls",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 1,
                column: "IsDeleted",
                value: false);

            migrationBuilder.UpdateData(
                table: "MembershipPackages",
                keyColumn: "Id",
                keyValue: 2,
                column: "IsDeleted",
                value: false);

            migrationBuilder.UpdateData(
                table: "MembershipPayments",
                keyColumn: "Id",
                keyValue: 1,
                column: "UpdatedAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "RecommendationSignals",
                keyColumn: "Id",
                keyValue: 1,
                column: "UpdatedAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "RecommendationSignals",
                keyColumn: "Id",
                keyValue: 2,
                column: "UpdatedAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "ReservationStatusAudits",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "SystemNotifications",
                keyColumn: "Id",
                keyValue: 1,
                column: "UpdatedAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "TrainingCategories",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 1,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 2,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 3,
                columns: new[] { "CreatedAtUtc", "UpdatedAtUtc" },
                values: new object[] { new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "UserMemberships",
                keyColumn: "Id",
                keyValue: 1,
                column: "IsDeleted",
                value: false);

            migrationBuilder.CreateIndex(
                name: "IX_UserAccounts_Email",
                table: "UserAccounts",
                column: "Email",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_UserAccounts_Username",
                table: "UserAccounts",
                column: "Username",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPackages_Name",
                table: "MembershipPackages",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_UserAccounts_Email",
                table: "UserAccounts");

            migrationBuilder.DropIndex(
                name: "IX_UserAccounts_Username",
                table: "UserAccounts");

            migrationBuilder.DropIndex(
                name: "IX_MembershipPackages_Name",
                table: "MembershipPackages");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "UserMemberships");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "TrainingEquipment");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "TrainingEquipment");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "TrainingCategories");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "TrainingCategories");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "SystemNotifications");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "ReservationStatusAudits");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "ReservationStatusAudits");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "RecommendationSignals");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "NewsItems");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "NewsItems");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "MembershipPayments");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "MembershipPackages");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "Halls");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "Halls");

            migrationBuilder.DropColumn(
                name: "CreatedAtUtc",
                table: "DifficultyLevels");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                table: "DifficultyLevels");

            migrationBuilder.CreateIndex(
                name: "IX_UserAccounts_Email",
                table: "UserAccounts",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_UserAccounts_Username",
                table: "UserAccounts",
                column: "Username",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPackages_Name",
                table: "MembershipPackages",
                column: "Name",
                unique: true);
        }
    }
}
