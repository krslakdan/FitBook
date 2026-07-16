using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class ReservationConfiguration : IEntityTypeConfiguration<Reservation>
{
    public void Configure(EntityTypeBuilder<Reservation> builder)
    {
        builder.ToTable("Reservations");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Status).IsRequired();
        builder.Property(x => x.ReservedAtUtc).IsRequired();
        builder.Property(x => x.CancellationReason).HasMaxLength(500);

        builder.HasIndex(x => new { x.UserAccountId, x.TrainingTermId })
            .IsUnique()
            .HasFilter("[Status] IN (1, 2)");
        builder.HasIndex(x => new { x.TrainingTermId, x.Status });
        builder.HasIndex(x => new { x.Status, x.ReminderSentAtUtc });

        builder.HasOne(x => x.UserAccount)
            .WithMany(x => x.Reservations)
            .HasForeignKey(x => x.UserAccountId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.TrainingTerm)
            .WithMany(x => x.Reservations)
            .HasForeignKey(x => x.TrainingTermId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.LastStatusChangedByUserAccount)
            .WithMany(x => x.ReservationStatusChanged)
            .HasForeignKey(x => x.LastStatusChangedByUserAccountId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
