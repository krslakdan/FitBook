using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddNewsItemAuthor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CreatedByUserAccountId",
                table: "NewsItems",
                type: "int",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 1,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 2,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 3,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 4,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 5,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 6,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 7,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 8,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 9,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "NewsItems",
                keyColumn: "Id",
                keyValue: 10,
                column: "CreatedByUserAccountId",
                value: 1);

            migrationBuilder.CreateIndex(
                name: "IX_NewsItems_CreatedByUserAccountId",
                table: "NewsItems",
                column: "CreatedByUserAccountId");

            migrationBuilder.AddForeignKey(
                name: "FK_NewsItems_UserAccounts_CreatedByUserAccountId",
                table: "NewsItems",
                column: "CreatedByUserAccountId",
                principalTable: "UserAccounts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_NewsItems_UserAccounts_CreatedByUserAccountId",
                table: "NewsItems");

            migrationBuilder.DropIndex(
                name: "IX_NewsItems_CreatedByUserAccountId",
                table: "NewsItems");

            migrationBuilder.DropColumn(
                name: "CreatedByUserAccountId",
                table: "NewsItems");
        }
    }
}
