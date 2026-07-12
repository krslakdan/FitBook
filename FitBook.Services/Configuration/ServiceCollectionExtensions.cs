using FitBook.Services.Mapping;
using FitBook.Services.Validators;
using FluentValidation;
using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Requests.Reservations;
using FitBook.Model.Requests.MembershipPackages;
using FitBook.Model.Requests.UserMemberships;
using Mapster;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using FitBook.Services.Interfaces.Auth;
using FitBook.Services.Auth;
using FitBook.Services.Interfaces;
using FitBook.Services.Payments;

namespace FitBook.Services.Configuration;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddFitBookServices(this IServiceCollection services)
    {
        var mapsterConfig = TypeAdapterConfig.GlobalSettings;
        mapsterConfig.Scan(typeof(UserAccountMappingConfig).Assembly);
        mapsterConfig.Scan(typeof(MembershipPackageMappingConfig).Assembly);
        mapsterConfig.Scan(typeof(UserMembershipMappingConfig).Assembly);

        services.AddSingleton(mapsterConfig);
        services.AddScoped<IMapper, ServiceMapper>();

        // Domain services
        services.AddScoped<IReservationService, ReservationService>();
        services.AddScoped<IUserAccountService, UserAccountService>();
        services.AddScoped<IMembershipPackageService, MembershipPackageService>();
        services.AddScoped<IUserMembershipService, UserMembershipService>();
        services.AddScoped<IStripePaymentService, StripePaymentService>();
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

        // MembershipPackage validators
        services.AddScoped<IValidator<MembershipPackageInsertRequest>, MembershipPackageInsertRequestValidator>();
        services.AddScoped<IValidator<MembershipPackageUpdateRequest>, MembershipPackageUpdateRequestValidator>();

        // UserMembership validators
        services.AddScoped<IValidator<UserMembershipInsertRequest>, UserMembershipInsertRequestValidator>();
        services.AddScoped<IValidator<UserMembershipUpdateRequest>, NullUserMembershipUpdateRequestValidator>();
        services.AddScoped<IValidator<UserMembershipCancelRequest>, UserMembershipCancelRequestValidator>();

        return services;
    }
}
