using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class ReservationStatusAuditConfiguration : IEntityTypeConfiguration<ReservationStatusAudit>
{
    public void Configure(EntityTypeBuilder<ReservationStatusAudit> builder)
    {
        builder.ToTable("ReservationStatusAudits");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.PreviousStatus).IsRequired();
        builder.Property(x => x.NewStatus).IsRequired();
        builder.Property(x => x.ChangedAtUtc).IsRequired();
        builder.Property(x => x.Reason).HasMaxLength(500);

        builder.HasIndex(x => new { x.ReservationId, x.ChangedAtUtc });

        builder.HasOne(x => x.Reservation)
            .WithMany(x => x.StatusAudits)
            .HasForeignKey(x => x.ReservationId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ChangedByUserAccount)
            .WithMany(x => x.ReservationStatusAudits)
            .HasForeignKey(x => x.ChangedByUserAccountId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
