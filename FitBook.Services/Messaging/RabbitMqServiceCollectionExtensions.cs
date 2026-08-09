using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace FitBook.Services.Messaging;

public static class RabbitMqServiceCollectionExtensions
{
    public static IServiceCollection AddRabbitMqOptions(this IServiceCollection services, IConfiguration configuration)
    {
        var section = configuration.GetSection(RabbitMqOptions.SectionName);
        var options = section.Get<RabbitMqOptions>() ?? new RabbitMqOptions();

        RequireValue(options.Host, "Host");
        RequireValue(options.Username, "Username");
        RequireValue(options.Password, "Password");
        RequireValue(options.NotificationQueue, "NotificationQueue");

        if (options.Port <= 0)
        {
            throw new InvalidOperationException(
                "RabbitMQ:Port configuration value is required but was not provided. Set it via the RabbitMQ__Port environment variable (.env).");
        }

        services.Configure<RabbitMqOptions>(section);

        return services;
    }

    private static void RequireValue(string value, string key)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidOperationException(
                $"RabbitMQ:{key} configuration value is required but was not provided. Set it via the RabbitMQ__{key} environment variable (.env).");
        }
    }
}
