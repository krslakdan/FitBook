using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddTrainerTermReminderSentAtUtc : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "TrainerReminderSentAtUtc",
                table: "TrainingTerms",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 1,
                column: "TrainerReminderSentAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 2,
                column: "TrainerReminderSentAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 3,
                column: "TrainerReminderSentAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 4,
                column: "TrainerReminderSentAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "TrainingTerms",
                keyColumn: "Id",
                keyValue: 5,
                column: "TrainerReminderSentAtUtc",
                value: null);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TrainerReminderSentAtUtc",
                table: "TrainingTerms");
        }
    }
}
