using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;

namespace FitBook.Services.Database;

public partial class FitBookDbContext : DbContext
{
    public FitBookDbContext(DbContextOptions<FitBookDbContext> options)
        : base(options)
    {
    }

    public DbSet<DifficultyLevel> DifficultyLevels { get; set; }
    public DbSet<Hall> Halls { get; set; }
    public DbSet<MembershipPackage> MembershipPackages { get; set; }
    public DbSet<MembershipPayment> MembershipPayments { get; set; }
    public DbSet<NewsItem> NewsItems { get; set; }
    public DbSet<RecommendationSignal> RecommendationSignals { get; set; }
    public DbSet<Reservation> Reservations { get; set; }
    public DbSet<ReservationStatusAudit> ReservationStatusAudits { get; set; }
    public DbSet<SystemNotification> SystemNotifications { get; set; }
    public DbSet<Trainer> Trainers { get; set; }
    public DbSet<Training> Trainings { get; set; }
    public DbSet<TrainingCategory> TrainingCategories { get; set; }
    public DbSet<TrainingEquipment> TrainingEquipment { get; set; }
    public DbSet<TrainingTerm> TrainingTerms { get; set; }
    public DbSet<UserAccount> UserAccounts { get; set; }
    public DbSet<UserMembership> UserMemberships { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(FitBookDbContext).Assembly);

        CreateSeed(modelBuilder);
    }
}
