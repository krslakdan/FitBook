using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class UserMembershipStatusAudits : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "UserMembershipStatusAudits",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PreviousStatus = table.Column<int>(type: "int", nullable: false),
                    NewStatus = table.Column<int>(type: "int", nullable: false),
                    ChangedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Reason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    UserMembershipId = table.Column<int>(type: "int", nullable: false),
                    ChangedByUserAccountId = table.Column<int>(type: "int", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserMembershipStatusAudits", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserMembershipStatusAudits_UserAccounts_ChangedByUserAccountId",
                        column: x => x.ChangedByUserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserMembershipStatusAudits_UserMemberships_UserMembershipId",
                        column: x => x.UserMembershipId,
                        principalTable: "UserMemberships",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_UserMembershipStatusAudits_ChangedByUserAccountId",
                table: "UserMembershipStatusAudits",
                column: "ChangedByUserAccountId");

            migrationBuilder.CreateIndex(
                name: "IX_UserMembershipStatusAudits_UserMembershipId_ChangedAtUtc",
                table: "UserMembershipStatusAudits",
                columns: new[] { "UserMembershipId", "ChangedAtUtc" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserMembershipStatusAudits");
        }
    }
}
