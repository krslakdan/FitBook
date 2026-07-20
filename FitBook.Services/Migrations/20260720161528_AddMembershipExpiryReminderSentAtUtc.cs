using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddMembershipExpiryReminderSentAtUtc : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ExpiryReminderSentAtUtc",
                table: "UserMemberships",
                type: "datetime2",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "UserMemberships",
                keyColumn: "Id",
                keyValue: 1,
                column: "ExpiryReminderSentAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "UserMemberships",
                keyColumn: "Id",
                keyValue: 2,
                column: "ExpiryReminderSentAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "UserMemberships",
                keyColumn: "Id",
                keyValue: 3,
                column: "ExpiryReminderSentAtUtc",
                value: null);

            migrationBuilder.UpdateData(
                table: "UserMemberships",
                keyColumn: "Id",
                keyValue: 4,
                column: "ExpiryReminderSentAtUtc",
                value: null);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ExpiryReminderSentAtUtc",
                table: "UserMemberships");
        }
    }
}
