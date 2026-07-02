using FitBook.Services.Mapping;
using Mapster;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;

namespace FitBook.Services.Configuration;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddFitBookServices(this IServiceCollection services)
    {
        var mapsterConfig = TypeAdapterConfig.GlobalSettings;
        mapsterConfig.Scan(typeof(UserAccountMappingConfig).Assembly);

        services.AddSingleton(mapsterConfig);
        services.AddScoped<IMapper, ServiceMapper>();

        services.AddScoped<IReservationService, ReservationService>();
        services.AddScoped<IUserAccountService, UserAccountService>();

        return services;
    }
}
