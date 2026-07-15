using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class FixSeedPaymentCurrency : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "MembershipPayments",
                keyColumn: "Id",
                keyValue: 1,
                column: "Currency",
                value: "USD");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "MembershipPayments",
                keyColumn: "Id",
                keyValue: 1,
                column: "Currency",
                value: "BAM");
        }
    }
}
