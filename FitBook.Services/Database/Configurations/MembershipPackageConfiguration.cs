using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class MembershipPackageConfiguration : IEntityTypeConfiguration<MembershipPackage>
{
    public void Configure(EntityTypeBuilder<MembershipPackage> builder)
    {
        builder.ToTable("MembershipPackages");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
        builder.Property(x => x.DurationDays).IsRequired();
        builder.Property(x => x.Price).HasColumnType("decimal(18,2)").IsRequired();
        builder.Property(x => x.SavingsAmount).HasColumnType("decimal(18,2)");
        builder.Property(x => x.IncludedBenefits).HasColumnType("nvarchar(max)").IsRequired();
        builder.Property(x => x.IsActive).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();

        builder.HasIndex(x => x.Name)
               .IsUnique()
               .HasFilter("[IsDeleted] = 0");
    }
}
