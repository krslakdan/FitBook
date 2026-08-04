namespace FitBook.Common.Services.Time;

public static class LocalTimeProvider
{
    private const string TimeZoneVariable = "APP_TIMEZONE";
    private const string DefaultTimeZoneId = "Europe/Sarajevo";

    private static readonly TimeZoneInfo Zone = ResolveZone();

    private static TimeZoneInfo ResolveZone()
    {
        var timeZoneId = Environment.GetEnvironmentVariable(TimeZoneVariable);
        if (string.IsNullOrWhiteSpace(timeZoneId))
        {
            timeZoneId = DefaultTimeZoneId;
        }

        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
        }
        catch (TimeZoneNotFoundException)
        {
            return TimeZoneInfo.Utc;
        }
        catch (InvalidTimeZoneException)
        {
            return TimeZoneInfo.Utc;
        }
    }

    public static DateTime ToLocal(DateTime utc)
    {
        return TimeZoneInfo.ConvertTimeFromUtc(DateTime.SpecifyKind(utc, DateTimeKind.Utc), Zone);
    }

    public static DateTime ToUtc(DateTime local)
    {
        var unspecified = DateTime.SpecifyKind(local, DateTimeKind.Unspecified);
        if (Zone.IsInvalidTime(unspecified))
        {
            unspecified = unspecified.AddHours(1);
        }

        return TimeZoneInfo.ConvertTimeToUtc(unspecified, Zone);
    }

    public static DateTime LocalDate(DateTime utc)
    {
        return ToLocal(utc).Date;
    }

    public static double OffsetHours(DateTime utc)
    {
        return Zone.GetUtcOffset(DateTime.SpecifyKind(utc, DateTimeKind.Utc)).TotalHours;
    }

    public static string FormatDateTime(DateTime utc)
    {
        return ToLocal(utc).ToString("dd.MM.yyyy. HH:mm");
    }

    public static string FormatDate(DateTime utc)
    {
        return ToLocal(utc).ToString("dd.MM.yyyy.");
    }
}
