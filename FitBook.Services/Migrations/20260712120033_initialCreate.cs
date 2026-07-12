using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FitBook.Services.Migrations
{
    /// <inheritdoc />
    public partial class initialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "DifficultyLevels",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DifficultyLevels", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Halls",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Capacity = table.Column<int>(type: "int", nullable: false),
                    LocationDescription = table.Column<string>(type: "nvarchar(250)", maxLength: 250, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Halls", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "MembershipPackages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    DurationDays = table.Column<int>(type: "int", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    SavingsAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    IncludedBenefits = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MembershipPackages", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "NewsItems",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Content = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    PublishedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NewsItems", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "TrainingCategories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TrainingCategories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "UserAccounts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    PhoneNumber = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    Username = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    Role = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    ProfileImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserAccounts", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Trainings",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    DurationMinutes = table.Column<int>(type: "int", nullable: false),
                    MaxParticipants = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    TrainingCategoryId = table.Column<int>(type: "int", nullable: false),
                    DifficultyLevelId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Trainings", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Trainings_DifficultyLevels_DifficultyLevelId",
                        column: x => x.DifficultyLevelId,
                        principalTable: "DifficultyLevels",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Trainings_TrainingCategories_TrainingCategoryId",
                        column: x => x.TrainingCategoryId,
                        principalTable: "TrainingCategories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "RefreshTokens",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Token = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ExpiresAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    RevokedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ReplacedByToken = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RefreshTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RefreshTokens_UserAccounts_UserId",
                        column: x => x.UserId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SystemNotifications",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Content = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: false),
                    IsRead = table.Column<bool>(type: "bit", nullable: false),
                    ReadAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    NotificationType = table.Column<int>(type: "int", nullable: false),
                    UserAccountId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SystemNotifications", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SystemNotifications_UserAccounts_UserAccountId",
                        column: x => x.UserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Trainers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    LastName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Specialization = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Biography = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IsAvailable = table.Column<bool>(type: "bit", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    UserAccountId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Trainers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Trainers_UserAccounts_UserAccountId",
                        column: x => x.UserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "UserMemberships",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StartDateUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndDateUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    NextPaymentDateUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Status = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    UserAccountId = table.Column<int>(type: "int", nullable: false),
                    MembershipPackageId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserMemberships", x => x.Id);
                    table.ForeignKey(
                        name: "FK_UserMemberships_MembershipPackages_MembershipPackageId",
                        column: x => x.MembershipPackageId,
                        principalTable: "MembershipPackages",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UserMemberships_UserAccounts_UserAccountId",
                        column: x => x.UserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "TrainingEquipment",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    IsRequired = table.Column<bool>(type: "bit", nullable: false),
                    Note = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: true),
                    TrainingId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TrainingEquipment", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TrainingEquipment_Trainings_TrainingId",
                        column: x => x.TrainingId,
                        principalTable: "Trainings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "TrainingTerms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StartTimeUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    EndTimeUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    MaxParticipants = table.Column<int>(type: "int", nullable: false),
                    Status = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    TrainingId = table.Column<int>(type: "int", nullable: false),
                    TrainerId = table.Column<int>(type: "int", nullable: false),
                    HallId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TrainingTerms", x => x.Id);
                    table.ForeignKey(
                        name: "FK_TrainingTerms_Halls_HallId",
                        column: x => x.HallId,
                        principalTable: "Halls",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_TrainingTerms_Trainers_TrainerId",
                        column: x => x.TrainerId,
                        principalTable: "Trainers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_TrainingTerms_Trainings_TrainingId",
                        column: x => x.TrainingId,
                        principalTable: "Trainings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MembershipPayments",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Amount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    Currency = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    PaymentProvider = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    PaymentIntentId = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    TransactionReference = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Status = table.Column<int>(type: "int", nullable: false),
                    PaidAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RefundedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RefundAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    UserMembershipId = table.Column<int>(type: "int", nullable: false),
                    UserAccountId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MembershipPayments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_MembershipPayments_UserAccounts_UserAccountId",
                        column: x => x.UserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MembershipPayments_UserMemberships_UserMembershipId",
                        column: x => x.UserMembershipId,
                        principalTable: "UserMemberships",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Reservations",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Status = table.Column<int>(type: "int", nullable: false),
                    ReservedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ConfirmedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CancelledAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CompletedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CancellationReason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    UserAccountId = table.Column<int>(type: "int", nullable: false),
                    TrainingTermId = table.Column<int>(type: "int", nullable: false),
                    LastStatusChangedByUserAccountId = table.Column<int>(type: "int", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reservations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Reservations_TrainingTerms_TrainingTermId",
                        column: x => x.TrainingTermId,
                        principalTable: "TrainingTerms",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Reservations_UserAccounts_LastStatusChangedByUserAccountId",
                        column: x => x.LastStatusChangedByUserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Reservations_UserAccounts_UserAccountId",
                        column: x => x.UserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "RecommendationSignals",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SignalType = table.Column<int>(type: "int", nullable: false),
                    Weight = table.Column<decimal>(type: "decimal(9,4)", nullable: false),
                    UserAccountId = table.Column<int>(type: "int", nullable: false),
                    TrainingId = table.Column<int>(type: "int", nullable: false),
                    TrainingCategoryId = table.Column<int>(type: "int", nullable: false),
                    ReservationId = table.Column<int>(type: "int", nullable: true),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RecommendationSignals", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RecommendationSignals_Reservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "Reservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RecommendationSignals_TrainingCategories_TrainingCategoryId",
                        column: x => x.TrainingCategoryId,
                        principalTable: "TrainingCategories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RecommendationSignals_Trainings_TrainingId",
                        column: x => x.TrainingId,
                        principalTable: "Trainings",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_RecommendationSignals_UserAccounts_UserAccountId",
                        column: x => x.UserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ReservationStatusAudits",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PreviousStatus = table.Column<int>(type: "int", nullable: false),
                    NewStatus = table.Column<int>(type: "int", nullable: false),
                    ChangedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Reason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    ReservationId = table.Column<int>(type: "int", nullable: false),
                    ChangedByUserAccountId = table.Column<int>(type: "int", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ReservationStatusAudits", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ReservationStatusAudits_Reservations_ReservationId",
                        column: x => x.ReservationId,
                        principalTable: "Reservations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ReservationStatusAudits_UserAccounts_ChangedByUserAccountId",
                        column: x => x.ChangedByUserAccountId,
                        principalTable: "UserAccounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "DifficultyLevels",
                columns: new[] { "Id", "CreatedAtUtc", "IsActive", "Name", "SortOrder", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Beginner", 1, null },
                    { 2, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Intermediate", 2, null },
                    { 3, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Advanced", 3, null }
                });

            migrationBuilder.InsertData(
                table: "Halls",
                columns: new[] { "Id", "Capacity", "CreatedAtUtc", "IsActive", "LocationDescription", "Name", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, 30, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Ground Floor, Zone A", "Main Gym Hall", null },
                    { 2, 15, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "First Floor, Zone B", "Yoga & Pilates Studio", null },
                    { 3, 20, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "First Floor, Zone C", "Spinning Room", null }
                });

            migrationBuilder.InsertData(
                table: "MembershipPackages",
                columns: new[] { "Id", "CreatedAtUtc", "DurationDays", "IncludedBenefits", "IsActive", "IsDeleted", "Name", "Price", "SavingsAmount", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 30, "Access to main hall, 3 group trainings per week.", true, false, "1 Month Basic", 50.00m, 0.00m, null },
                    { 2, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), 90, "Unlimited group trainings, sauna access, 1 free personal session.", true, false, "3 Month Premium", 120.00m, 30.00m, null }
                });

            migrationBuilder.InsertData(
                table: "NewsItems",
                columns: new[] { "Id", "Content", "CreatedAtUtc", "ImageUrl", "IsActive", "PublishedAtUtc", "Title", "UpdatedAtUtc" },
                values: new object[] { 1, "We are thrilled to announce that our new premium Yoga & Pilates studio on the first floor is now open for bookings.", new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "uploads/news/yoga_opening.jpg", true, new DateTime(2026, 6, 15, 9, 0, 0, 0, DateTimeKind.Utc), "Grand Opening of our Yoga Studio!", null });

            migrationBuilder.InsertData(
                table: "TrainingCategories",
                columns: new[] { "Id", "CreatedAtUtc", "Description", "IsActive", "Name", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Workouts designed to improve heart health and stamina.", true, "Cardio", null },
                    { 2, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Resistance training designed to build muscle mass.", true, "Strength", null },
                    { 3, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), "Yoga, stretching, and mindfulness practices.", true, "Mind & Body", null }
                });

            migrationBuilder.InsertData(
                table: "UserAccounts",
                columns: new[] { "Id", "CreatedAtUtc", "Email", "FirstName", "IsActive", "IsDeleted", "LastName", "PasswordHash", "PhoneNumber", "ProfileImageUrl", "Role", "UpdatedAtUtc", "Username" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "admin@fitbook.com", "System", true, false, "Administrator", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761111222", "uploads/users/admin.jpg", "Admin", null, "desktop" },
                    { 2, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "user@fitbook.com", "John", true, false, "Client", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761333444", "uploads/users/john.jpg", "User", null, "mobile" },
                    { 3, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "johndoe@fitbook.com", "John", true, false, "Doe", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555001", "uploads/trainers/trainer1.jpg", "Trainer", null, "johndoe" },
                    { 4, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "janesmith@fitbook.com", "Jane", true, false, "Smith", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555002", "uploads/trainers/trainer2.jpg", "Trainer", null, "janesmith" },
                    { 5, new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "mikejones@fitbook.com", "Mike", true, false, "Jones", "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46", "+38761555003", "uploads/trainers/trainer3.jpg", "Trainer", null, "mikejones" }
                });

            migrationBuilder.InsertData(
                table: "SystemNotifications",
                columns: new[] { "Id", "Content", "CreatedAtUtc", "IsRead", "NotificationType", "ReadAtUtc", "Title", "UpdatedAtUtc", "UserAccountId" },
                values: new object[] { 1, "Your reservation for Vinyasa Yoga has been successfully confirmed.", new DateTime(2026, 6, 23, 10, 15, 0, 0, DateTimeKind.Utc), false, 2, null, "Reservation Confirmed", null, 2 });

            migrationBuilder.InsertData(
                table: "Trainers",
                columns: new[] { "Id", "Biography", "CreatedAtUtc", "FirstName", "ImageUrl", "IsActive", "IsAvailable", "LastName", "Specialization", "UpdatedAtUtc", "UserAccountId" },
                values: new object[,]
                {
                    { 1, "Certified trainer with 8+ years of experience in athletic training.", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "John", "uploads/trainers/trainer1.jpg", true, true, "Doe", "Strength & Conditioning", null, 3 },
                    { 2, "Passionate about helping people find balance and flexibility.", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Jane", "uploads/trainers/trainer2.jpg", true, true, "Smith", "Yoga & Pilates", null, 4 },
                    { 3, "Energy-packed HIIT workouts to keep you burning calories.", new DateTime(2026, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc), "Mike", "uploads/trainers/trainer3.jpg", true, true, "Jones", "Cardio & HIIT", null, 5 }
                });

            migrationBuilder.InsertData(
                table: "Trainings",
                columns: new[] { "Id", "CreatedAtUtc", "Description", "DifficultyLevelId", "DurationMinutes", "IsActive", "MaxParticipants", "Name", "TrainingCategoryId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 1, 10, 0, 0, 0, 0, DateTimeKind.Utc), "High Intensity Interval Training to boost metabolism.", 2, 45, true, 20, "HIIT Blast", 1, null },
                    { 2, new DateTime(2026, 1, 10, 0, 0, 0, 0, DateTimeKind.Utc), "Learn and execute proper barbell techniques.", 3, 60, true, 10, "Power Lifting", 2, null },
                    { 3, new DateTime(2026, 1, 10, 0, 0, 0, 0, DateTimeKind.Utc), "Flowing sequences of yoga poses with breath control.", 1, 60, true, 15, "Vinyasa Yoga", 3, null }
                });

            migrationBuilder.InsertData(
                table: "UserMemberships",
                columns: new[] { "Id", "CreatedAtUtc", "EndDateUtc", "IsActive", "IsDeleted", "MembershipPackageId", "NextPaymentDateUtc", "StartDateUtc", "Status", "UpdatedAtUtc", "UserAccountId" },
                values: new object[] { 1, new DateTime(2026, 5, 30, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Utc), true, false, 1, new DateTime(2026, 7, 1, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 6, 1, 0, 0, 0, 0, DateTimeKind.Utc), 2, null, 2 });

            migrationBuilder.InsertData(
                table: "MembershipPayments",
                columns: new[] { "Id", "Amount", "CreatedAtUtc", "Currency", "PaidAtUtc", "PaymentIntentId", "PaymentProvider", "RefundAmount", "RefundedAtUtc", "Status", "TransactionReference", "UpdatedAtUtc", "UserAccountId", "UserMembershipId" },
                values: new object[] { 1, 50.00m, new DateTime(2026, 5, 30, 10, 0, 0, 0, DateTimeKind.Utc), "BAM", new DateTime(2026, 5, 30, 10, 5, 0, 0, DateTimeKind.Utc), "pi_1234567890", "Stripe", null, null, 2, "tx_998877", null, 2, 1 });

            migrationBuilder.InsertData(
                table: "TrainingEquipment",
                columns: new[] { "Id", "CreatedAtUtc", "IsRequired", "Name", "Note", "TrainingId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Kettlebell", "Recommended 8kg-16kg", 1, null },
                    { 2, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), true, "Barbell Set", "Belts provided in hall", 2, null },
                    { 3, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), false, "Yoga Mat", "Mats are available in studio, or bring your own", 3, null }
                });

            migrationBuilder.InsertData(
                table: "TrainingTerms",
                columns: new[] { "Id", "CreatedAtUtc", "EndTimeUtc", "HallId", "IsActive", "MaxParticipants", "StartTimeUtc", "Status", "TrainerId", "TrainingId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 6, 20, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 6, 25, 10, 45, 0, 0, DateTimeKind.Utc), 3, true, 20, new DateTime(2026, 6, 25, 10, 0, 0, 0, DateTimeKind.Utc), 3, 3, 1, null },
                    { 2, new DateTime(2026, 6, 20, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 6, 26, 13, 0, 0, 0, DateTimeKind.Utc), 1, true, 10, new DateTime(2026, 6, 26, 12, 0, 0, 0, DateTimeKind.Utc), 3, 1, 2, null },
                    { 3, new DateTime(2026, 6, 20, 0, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 7, 5, 9, 0, 0, 0, DateTimeKind.Utc), 2, true, 15, new DateTime(2026, 7, 5, 8, 0, 0, 0, DateTimeKind.Utc), 1, 2, 3, null }
                });

            migrationBuilder.InsertData(
                table: "Reservations",
                columns: new[] { "Id", "CancellationReason", "CancelledAtUtc", "CompletedAtUtc", "ConfirmedAtUtc", "CreatedAtUtc", "LastStatusChangedByUserAccountId", "ReservedAtUtc", "Status", "TrainingTermId", "UpdatedAtUtc", "UserAccountId" },
                values: new object[,]
                {
                    { 1, null, null, new DateTime(2026, 6, 25, 11, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 6, 21, 15, 10, 0, 0, DateTimeKind.Utc), new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2026, 6, 21, 15, 0, 0, 0, DateTimeKind.Utc), 4, 1, null, 2 },
                    { 2, null, null, new DateTime(2026, 6, 26, 13, 0, 0, 0, DateTimeKind.Utc), new DateTime(2026, 6, 22, 16, 5, 0, 0, DateTimeKind.Utc), new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2026, 6, 22, 16, 0, 0, 0, DateTimeKind.Utc), 4, 2, null, 2 },
                    { 3, null, null, null, new DateTime(2026, 6, 23, 10, 15, 0, 0, DateTimeKind.Utc), new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), null, new DateTime(2026, 6, 23, 10, 0, 0, 0, DateTimeKind.Utc), 2, 3, null, 2 }
                });

            migrationBuilder.InsertData(
                table: "RecommendationSignals",
                columns: new[] { "Id", "CreatedAtUtc", "ReservationId", "SignalType", "TrainingCategoryId", "TrainingId", "UpdatedAtUtc", "UserAccountId", "Weight" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 6, 25, 11, 0, 0, 0, DateTimeKind.Utc), 1, 4, 1, 1, null, 2, 1.0m },
                    { 2, new DateTime(2026, 6, 26, 13, 0, 0, 0, DateTimeKind.Utc), 2, 4, 2, 2, null, 2, 1.0m }
                });

            migrationBuilder.InsertData(
                table: "ReservationStatusAudits",
                columns: new[] { "Id", "ChangedAtUtc", "ChangedByUserAccountId", "CreatedAtUtc", "NewStatus", "PreviousStatus", "Reason", "ReservationId", "UpdatedAtUtc" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 6, 21, 15, 10, 0, 0, DateTimeKind.Utc), 1, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 1, "Auto-confirmed on successful payment and active membership check", 1, null },
                    { 2, new DateTime(2026, 6, 25, 11, 0, 0, 0, DateTimeKind.Utc), 5, new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 2, "Marked as completed after class finish", 1, null }
                });

            migrationBuilder.CreateIndex(
                name: "IX_DifficultyLevels_Name",
                table: "DifficultyLevels",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Halls_Name",
                table: "Halls",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPackages_Name",
                table: "MembershipPackages",
                column: "Name",
                unique: true,
                filter: "[IsDeleted] = 0");

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPayments_PaymentIntentId",
                table: "MembershipPayments",
                column: "PaymentIntentId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPayments_UserAccountId",
                table: "MembershipPayments",
                column: "UserAccountId");

            migrationBuilder.CreateIndex(
                name: "IX_MembershipPayments_UserMembershipId_Status",
                table: "MembershipPayments",
                columns: new[] { "UserMembershipId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_NewsItems_PublishedAtUtc",
                table: "NewsItems",
                column: "PublishedAtUtc");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendationSignals_ReservationId",
                table: "RecommendationSignals",
                column: "ReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendationSignals_TrainingCategoryId",
                table: "RecommendationSignals",
                column: "TrainingCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendationSignals_TrainingId",
                table: "RecommendationSignals",
                column: "TrainingId");

            migrationBuilder.CreateIndex(
                name: "IX_RecommendationSignals_UserAccountId_SignalType",
                table: "RecommendationSignals",
                columns: new[] { "UserAccountId", "SignalType" });

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_Token",
                table: "RefreshTokens",
                column: "Token",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_UserId",
                table: "RefreshTokens",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_LastStatusChangedByUserAccountId",
                table: "Reservations",
                column: "LastStatusChangedByUserAccountId");

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_TrainingTermId_Status",
                table: "Reservations",
                columns: new[] { "TrainingTermId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_Reservations_UserAccountId_TrainingTermId",
                table: "Reservations",
                columns: new[] { "UserAccountId", "TrainingTermId" },
                unique: true,
                filter: "[Status] IN (1, 2)");

            migrationBuilder.CreateIndex(
                name: "IX_ReservationStatusAudits_ChangedByUserAccountId",
                table: "ReservationStatusAudits",
                column: "ChangedByUserAccountId");

            migrationBuilder.CreateIndex(
                name: "IX_ReservationStatusAudits_ReservationId_ChangedAtUtc",
                table: "ReservationStatusAudits",
                columns: new[] { "ReservationId", "ChangedAtUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_SystemNotifications_UserAccountId_IsRead",
                table: "SystemNotifications",
                columns: new[] { "UserAccountId", "IsRead" });

            migrationBuilder.CreateIndex(
                name: "IX_Trainers_UserAccountId",
                table: "Trainers",
                column: "UserAccountId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TrainingCategories_Name",
                table: "TrainingCategories",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TrainingEquipment_TrainingId_Name",
                table: "TrainingEquipment",
                columns: new[] { "TrainingId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Trainings_DifficultyLevelId",
                table: "Trainings",
                column: "DifficultyLevelId");

            migrationBuilder.CreateIndex(
                name: "IX_Trainings_Name",
                table: "Trainings",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_Trainings_TrainingCategoryId",
                table: "Trainings",
                column: "TrainingCategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingTerms_HallId",
                table: "TrainingTerms",
                column: "HallId");

            migrationBuilder.CreateIndex(
                name: "IX_TrainingTerms_TrainerId_StartTimeUtc_EndTimeUtc",
                table: "TrainingTerms",
                columns: new[] { "TrainerId", "StartTimeUtc", "EndTimeUtc" });

            migrationBuilder.CreateIndex(
                name: "IX_TrainingTerms_TrainingId_StartTimeUtc",
                table: "TrainingTerms",
                columns: new[] { "TrainingId", "StartTimeUtc" });

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
                name: "IX_UserMemberships_MembershipPackageId",
                table: "UserMemberships",
                column: "MembershipPackageId");

            migrationBuilder.CreateIndex(
                name: "IX_UserMemberships_UserAccountId",
                table: "UserMemberships",
                column: "UserAccountId",
                unique: true,
                filter: "[IsActive] = 1");

            migrationBuilder.CreateIndex(
                name: "IX_UserMemberships_UserAccountId_IsActive",
                table: "UserMemberships",
                columns: new[] { "UserAccountId", "IsActive" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MembershipPayments");

            migrationBuilder.DropTable(
                name: "NewsItems");

            migrationBuilder.DropTable(
                name: "RecommendationSignals");

            migrationBuilder.DropTable(
                name: "RefreshTokens");

            migrationBuilder.DropTable(
                name: "ReservationStatusAudits");

            migrationBuilder.DropTable(
                name: "SystemNotifications");

            migrationBuilder.DropTable(
                name: "TrainingEquipment");

            migrationBuilder.DropTable(
                name: "UserMemberships");

            migrationBuilder.DropTable(
                name: "Reservations");

            migrationBuilder.DropTable(
                name: "MembershipPackages");

            migrationBuilder.DropTable(
                name: "TrainingTerms");

            migrationBuilder.DropTable(
                name: "Halls");

            migrationBuilder.DropTable(
                name: "Trainers");

            migrationBuilder.DropTable(
                name: "Trainings");

            migrationBuilder.DropTable(
                name: "UserAccounts");

            migrationBuilder.DropTable(
                name: "DifficultyLevels");

            migrationBuilder.DropTable(
                name: "TrainingCategories");
        }
    }
}
