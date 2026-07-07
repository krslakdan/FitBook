using FitBook.Services.Mapping;
using FitBook.Services.Validators;
using FluentValidation;
using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Requests.Reservations;
using Mapster;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using FitBook.Services.Interfaces.Auth;
using FitBook.Services.Auth;
using FitBook.Services.Interfaces;

namespace FitBook.Services.Configuration;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddFitBookServices(this IServiceCollection services)
    {
        var mapsterConfig = TypeAdapterConfig.GlobalSettings;
        mapsterConfig.Scan(typeof(UserAccountMappingConfig).Assembly);

        services.AddSingleton(mapsterConfig);
        services.AddScoped<IMapper, ServiceMapper>();

        // Domain services
        services.AddScoped<IReservationService, ReservationService>();
        services.AddScoped<IUserAccountService, UserAccountService>();
        services.AddScoped<IJwtTokenService, JwtTokenService>();
        services.AddScoped<IRefreshTokenService, RefreshTokenService>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<ICurrentUserService, CurrentUserService>();

        // UserAccount validators
        services.AddScoped<IValidator<UserAccountInsertRequest>, UserAccountInsertRequestValidator>();
        services.AddScoped<IValidator<UserAccountUpdateRequest>, UserAccountUpdateRequestValidator>();
        services.AddScoped<IValidator<UserAccountChangeOwnPasswordRequest>, UserAccountChangeOwnPasswordRequestValidator>();
        services.AddScoped<IValidator<UserAccountAdminPasswordResetRequest>, UserAccountAdminPasswordResetRequestValidator>();

        // Reservation validators
        services.AddScoped<IValidator<ReservationInsertRequest>, ReservationInsertRequestValidator>();
        services.AddScoped<IValidator<ReservationUpdateRequest>, NullReservationUpdateRequestValidator>();
        services.AddScoped<IValidator<ReservationCancelRequest>, ReservationCancelRequestValidator>();

        return services;
    }
}
