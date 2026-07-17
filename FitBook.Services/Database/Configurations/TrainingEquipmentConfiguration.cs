using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class TrainingEquipmentConfiguration : IEntityTypeConfiguration<TrainingEquipment>
{
    public void Configure(EntityTypeBuilder<TrainingEquipment> builder)
    {
        builder.ToTable("TrainingEquipment");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.IsRequired).IsRequired();
        builder.Property(x => x.Note).HasMaxLength(300);

        builder.HasIndex(x => new { x.TrainingId, x.EquipmentId }).IsUnique();

        builder.HasOne(x => x.Training)
            .WithMany(x => x.EquipmentItems)
            .HasForeignKey(x => x.TrainingId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Equipment)
            .WithMany(x => x.TrainingEquipmentItems)
            .HasForeignKey(x => x.EquipmentId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
