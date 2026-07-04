using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class UserMembershipConfiguration : IEntityTypeConfiguration<UserMembership>
{
    public void Configure(EntityTypeBuilder<UserMembership> builder)
    {
        builder.ToTable("UserMemberships");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.StartDateUtc).IsRequired();
        builder.Property(x => x.EndDateUtc).IsRequired();
        builder.Property(x => x.Status).IsRequired();
        builder.Property(x => x.IsActive).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();

        builder.HasIndex(x => new { x.UserAccountId, x.IsActive });

        builder.HasIndex(x => x.UserAccountId)
            .IsUnique()
            .HasFilter("[IsActive] = 1");

        builder.HasOne(x => x.UserAccount)
            .WithMany(x => x.Memberships)
            .HasForeignKey(x => x.UserAccountId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.MembershipPackage)
            .WithMany(x => x.UserMemberships)
            .HasForeignKey(x => x.MembershipPackageId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
