using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class UserMembershipStatusAuditConfiguration : IEntityTypeConfiguration<UserMembershipStatusAudit>
{
    public void Configure(EntityTypeBuilder<UserMembershipStatusAudit> builder)
    {
        builder.ToTable("UserMembershipStatusAudits");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.PreviousStatus).IsRequired();
        builder.Property(x => x.NewStatus).IsRequired();
        builder.Property(x => x.ChangedAtUtc).IsRequired();
        builder.Property(x => x.Reason).HasMaxLength(500);

        builder.HasIndex(x => new { x.UserMembershipId, x.ChangedAtUtc });

        builder.HasOne(x => x.UserMembership)
            .WithMany(x => x.StatusAudits)
            .HasForeignKey(x => x.UserMembershipId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ChangedByUserAccount)
            .WithMany(x => x.UserMembershipStatusAudits)
            .HasForeignKey(x => x.ChangedByUserAccountId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
