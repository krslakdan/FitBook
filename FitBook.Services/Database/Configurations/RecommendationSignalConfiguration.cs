using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class RecommendationSignalConfiguration : IEntityTypeConfiguration<RecommendationSignal>
{
    public void Configure(EntityTypeBuilder<RecommendationSignal> builder)
    {
        builder.ToTable("RecommendationSignals");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.SignalType).IsRequired();
        builder.Property(x => x.Weight).HasColumnType("decimal(9,4)").IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();

        builder.HasOne(x => x.UserAccount)
            .WithMany(x => x.RecommendationSignals)
            .HasForeignKey(x => x.UserAccountId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Training)
            .WithMany(x => x.RecommendationSignals)
            .HasForeignKey(x => x.TrainingId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.TrainingCategory)
            .WithMany(x => x.RecommendationSignals)
            .HasForeignKey(x => x.TrainingCategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Reservation)
            .WithMany(x => x.RecommendationSignals)
            .HasForeignKey(x => x.ReservationId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(x => new { x.UserAccountId, x.SignalType });
    }
}
