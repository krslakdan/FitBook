using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddReservationReminderSentAtUtc : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ReminderSentAtUtc",
                table: "Reservations",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 1,
                column: "ReminderSentAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 2,
                column: "ReminderSentAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "Reservations",
                keyColumn: "Id",
                keyValue: 3,
                column: "ReminderSentAtUtc",
                value: null);

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_Status_ReminderSentAtUtc",
                table: "Reservations",
                columns: new[] { "Status", "ReminderSentAtUtc" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Reservations_Status_ReminderSentAtUtc",
                table: "Reservations");

            migrationBuilder.DropColumn(
                name: "ReminderSentAtUtc",
                table: "Reservations");
        }
    }
}
