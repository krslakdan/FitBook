using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class TrainingTermConfiguration : IEntityTypeConfiguration<TrainingTerm>
{
    public void Configure(EntityTypeBuilder<TrainingTerm> builder)
    {
        builder.ToTable("TrainingTerms");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.StartTimeUtc).IsRequired();
        builder.Property(x => x.EndTimeUtc).IsRequired();
        builder.Property(x => x.MaxParticipants).IsRequired();
        builder.Property(x => x.Status).IsRequired();
        builder.Property(x => x.IsActive).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();

        builder.HasIndex(x => new { x.TrainingId, x.StartTimeUtc });
        builder.HasIndex(x => new { x.TrainerId, x.StartTimeUtc, x.EndTimeUtc });

        builder.HasOne(x => x.Training)
            .WithMany(x => x.TrainingTerms)
            .HasForeignKey(x => x.TrainingId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Trainer)
            .WithMany(x => x.TrainingTerms)
            .HasForeignKey(x => x.TrainerId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Hall)
            .WithMany(x => x.TrainingTerms)
            .HasForeignKey(x => x.HallId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
