using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class PasswordResetTokenConfiguration : IEntityTypeConfiguration<PasswordResetToken>
{
    public void Configure(EntityTypeBuilder<PasswordResetToken> builder)
    {
        builder.HasKey(x => x.Id);

        builder.Property(x => x.CodeHash)
            .IsRequired()
            .HasMaxLength(200);

        builder.HasOne(x => x.UserAccount)
            .WithMany()
            .HasForeignKey(x => x.UserAccountId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(x => x.UserAccountId);
    }
}
