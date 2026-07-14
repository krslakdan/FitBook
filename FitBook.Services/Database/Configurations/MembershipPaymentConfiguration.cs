using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class MembershipPaymentConfiguration : IEntityTypeConfiguration<MembershipPayment>
{
    public void Configure(EntityTypeBuilder<MembershipPayment> builder)
    {
        builder.ToTable("MembershipPayments");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Amount).HasColumnType("decimal(18,2)").IsRequired();
        builder.Property(x => x.Currency).HasMaxLength(10).IsRequired();
        builder.Property(x => x.PaymentProvider).HasMaxLength(50).IsRequired();
        builder.Property(x => x.PaymentIntentId).HasMaxLength(200).IsRequired();
        builder.Property(x => x.TransactionReference).HasMaxLength(200);
        builder.Property(x => x.Status).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.RefundAmount).HasColumnType("decimal(18,2)");

        builder.HasIndex(x => x.PaymentIntentId).IsUnique();
        builder.HasIndex(x => new { x.UserMembershipId, x.Status });

        builder.HasIndex(x => x.UserMembershipId)
            .IsUnique()
            .HasFilter("[Status] IN (1, 2)")
            .HasDatabaseName("IX_MembershipPayments_UserMembershipId_ActiveOnly");

        builder.HasOne(x => x.UserMembership)
            .WithMany(x => x.Payments)
            .HasForeignKey(x => x.UserMembershipId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.UserAccount)
            .WithMany(x => x.Payments)
            .HasForeignKey(x => x.UserAccountId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
