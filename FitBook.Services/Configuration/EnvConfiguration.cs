namespace FitBook.Services.Configuration;

public static class EnvConfiguration
{
    private static readonly HashSet<string> ExcludedKeys =
    [
        "ASPNETCORE_URLS"
    ];

    public static void LoadDotEnv()
    {
        var envPath = FindEnvFile();
        if (envPath is null)
        {
            return;
        }

        foreach (var rawLine in File.ReadAllLines(envPath))
        {
            var line = rawLine.Trim();
            if (string.IsNullOrEmpty(line) || line.StartsWith('#'))
            {
                continue;
            }

            var separatorIndex = line.IndexOf('=');
            if (separatorIndex <= 0)
            {
                continue;
            }

            var key = line[..separatorIndex].Trim();
            if (ExcludedKeys.Contains(key))
            {
                continue;
            }

            var value = line[(separatorIndex + 1)..].Trim().Trim('"');

            if (!string.IsNullOrEmpty(key))
            {
                Environment.SetEnvironmentVariable(key, value);
            }
        }
    }

    private static string? FindEnvFile()
    {
        var directory = Directory.GetCurrentDirectory();

        while (!string.IsNullOrEmpty(directory))
        {
            var envPath = Path.Combine(directory, ".env");
            if (File.Exists(envPath))
            {
                return envPath;
            }

            directory = Directory.GetParent(directory)?.FullName ?? string.Empty;
        }

        return null;
    }
}
