using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddUserAccountTokenVersion : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TokenVersion",
                table: "UserAccounts",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 1,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 2,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 3,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 4,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 5,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 6,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 7,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 8,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 9,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 10,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 11,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 12,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 13,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 14,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 15,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 16,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 17,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 18,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 19,
                column: "TokenVersion",
                value: 0);

            migrationBuilder.UpdateData(
                table: "UserAccounts",
                keyColumn: "Id",
                keyValue: 20,
                column: "TokenVersion",
                value: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TokenVersion",
                table: "UserAccounts");
        }
    }
}
