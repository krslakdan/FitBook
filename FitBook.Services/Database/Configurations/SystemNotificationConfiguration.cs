using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class SystemNotificationConfiguration : IEntityTypeConfiguration<SystemNotification>
{
    public void Configure(EntityTypeBuilder<SystemNotification> builder)
    {
        builder.ToTable("SystemNotifications");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Title).HasMaxLength(200).IsRequired();
        builder.Property(x => x.Content).HasMaxLength(2000).IsRequired();
        builder.Property(x => x.IsRead).IsRequired();
        builder.Property(x => x.CreatedAtUtc).IsRequired();
        builder.Property(x => x.NotificationType).IsRequired();

        builder.HasOne(x => x.UserAccount)
            .WithMany(x => x.Notifications)
            .HasForeignKey(x => x.UserAccountId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(x => new { x.UserAccountId, x.IsRead });
    }
}
