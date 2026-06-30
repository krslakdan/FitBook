using FitBook.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FitBook.Services.Database.Configurations;

public class TrainingCategoryConfiguration : IEntityTypeConfiguration<TrainingCategory>
{
    public void Configure(EntityTypeBuilder<TrainingCategory> builder)
    {
        builder.ToTable("TrainingCategories");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Name).HasMaxLength(120).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(500);
        builder.Property(x => x.IsActive).IsRequired();

        builder.HasIndex(x => x.Name).IsUnique();
    }
}
