using FitBook.Common.Services.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace FitBook.Services.Database;

public class FitBookDbContextFactory : IDesignTimeDbContextFactory<FitBookDbContext>
{
    public FitBookDbContext CreateDbContext(string[] args)
    {
        EnvConfiguration.LoadDotEnv();

        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "Connection string 'DefaultConnection' was not found. " +
                "Create a .env file at the solution root with ConnectionStrings__DefaultConnection.");
        }

        var optionsBuilder = new DbContextOptionsBuilder<FitBookDbContext>();
        optionsBuilder.UseSqlServer(connectionString);

        return new FitBookDbContext(optionsBuilder.Options);
    }
}
