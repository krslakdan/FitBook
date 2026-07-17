using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class EquipmentCatalogManyToMany : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_TrainingEquipment_TrainingId_Name",
                table: "TrainingEquipment");

            migrationBuilder.DropColumn(
                name: "Name",
                table: "TrainingEquipment");

            migrationBuilder.AddColumn<int>(
                name: "EquipmentId",
                table: "TrainingEquipment",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "Equipment",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Equipment", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "Equipment",
                columns: new[] { "Id", "CreatedAtUtc", "IsActive", "Name", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Kettlebell", null },
                    { 2, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Barbell Set", null },
                    { 3, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Yoga Mat", null },
                    { 4, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Foam Roller", null },
                    { 5, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Boxing Gloves", null }
                });

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 1,
                column: "EquipmentId",
                value: 1);

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 2,
                column: "EquipmentId",
                value: 2);

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 3,
                column: "EquipmentId",
                value: 3);

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 4,
                column: "EquipmentId",
                value: 4);

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 5,
                column: "EquipmentId",
                value: 5);

            migrationBuilder.CreateIndex(
                name: "IX_TrainingEquipment_EquipmentId",
                table: "TrainingEquipment",
                column: "EquipmentId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingEquipment_TrainingId_EquipmentId",
                table: "TrainingEquipment",
                columns: new[] { "TrainingId", "EquipmentId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Equipment_Name",
                table: "Equipment",
                column: "Name",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_TrainingEquipment_Equipment_EquipmentId",
                table: "TrainingEquipment",
                column: "EquipmentId",
                principalTable: "Equipment",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TrainingEquipment_Equipment_EquipmentId",
                table: "TrainingEquipment");

            migrationBuilder.DropTable(
                name: "Equipment");

            migrationBuilder.DropIndex(
                name: "IX_TrainingEquipment_EquipmentId",
                table: "TrainingEquipment");

            migrationBuilder.DropIndex(
                name: "IX_TrainingEquipment_TrainingId_EquipmentId",
                table: "TrainingEquipment");

            migrationBuilder.DropColumn(
                name: "EquipmentId",
                table: "TrainingEquipment");

            migrationBuilder.AddColumn<string>(
                name: "Name",
                table: "TrainingEquipment",
                type: "nvarchar(120)",
                maxLength: 120,
                nullable: false,
                defaultValue: "");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 1,
                column: "Name",
                value: "Kettlebell");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 2,
                column: "Name",
                value: "Barbell Set");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 3,
                column: "Name",
                value: "Yoga Mat");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 4,
                column: "Name",
                value: "Foam Roller");

            migrationBuilder.UpdateData(
                table: "TrainingEquipment",
                keyColumn: "Id",
                keyValue: 5,
                column: "Name",
                value: "Boxing Gloves");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingEquipment_TrainingId_Name",
                table: "TrainingEquipment",
                columns: new[] { "TrainingId", "Name" },
                unique: true);
        }
    }
}
