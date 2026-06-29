using Microsoft.EntityFrameworkCore;

namespace FitBook.Services.Database;

public class FitBookDbContext : DbContext
{
    public FitBookDbContext(DbContextOptions<FitBookDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure all foreign keys and seed data here.
        // Add DbSet<T> properties as FitBook entities are implemented.
    }
}
