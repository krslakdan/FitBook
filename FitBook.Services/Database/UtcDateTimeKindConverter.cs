using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace FitBook.Services.Database;

public class UtcDateTimeKindConverter : ValueConverter<DateTime, DateTime>
{
    public UtcDateTimeKindConverter()
        : base(value => value, value => DateTime.SpecifyKind(value, DateTimeKind.Utc))
    {
    }
}
