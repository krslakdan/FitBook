using FitBook.Services.Mapping;
using FitBook.Services.Validators;
using FluentValidation;
using FitBook.Model.Requests.UserAccounts;
using FitBook.Model.Requests.Reservations;
using FitBook.Model.Requests.MembershipPackages;
using FitBook.Model.Requests.UserMemberships;
using FitBook.Model.Requests.TrainingCategories;
using FitBook.Model.Requests.DifficultyLevels;
using FitBook.Model.Requests.Equipment;
using FitBook.Model.Requests.Halls;
using FitBook.Model.Requests.TrainingEquipment;
using FitBook.Model.Requests.Trainers;
using FitBook.Model.Requests.Trainings;
using FitBook.Model.Requests.TrainingTerms;
using FitBook.Model.Requests.NewsItems;
using FitBook.Model.Requests.Specializations;
using FitBook.Model.Requests.Reports;
using Mapster;
using MapsterMapper;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using FitBook.Services.Interfaces.Auth;
using FitBook.Services.Auth;
using FitBook.Services.Interfaces;
using FitBook.Services.Messaging;
using FitBook.Services.Payments;
using FitBook.Services.Reports;

namespace FitBook.Services.Configuration;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddFitBookServices(this IServiceCollection services, IConfiguration configuration)
    {
        var mapsterConfig = TypeAdapterConfig.GlobalSettings;
        mapsterConfig.Scan(typeof(UserAccountMappingConfig).Assembly);
        // By scanning the assembly containing UserAccountMappingConfig, 
        // all other mapping configs in the same assembly will be registered automatically.
        // E.g., TrainingCategoryMappingConfig, TrainerMappingConfig, etc.

        services.AddSingleton(mapsterConfig);
        services.AddScoped<IMapper, ServiceMapper>();

        // Domain services
        services.AddScoped<IReservationService, ReservationService>();
        services.AddScoped<IUserAccountService, UserAccountService>();
        services.AddScoped<IMembershipPackageService, MembershipPackageService>();
        services.AddScoped<IUserMembershipService, UserMembershipService>();
        services.AddScoped<IStripePaymentService, StripePaymentService>();
        
        services.AddScoped<ITrainingCategoryService, TrainingCategoryService>();
        services.AddScoped<IDifficultyLevelService, DifficultyLevelService>();
        services.AddScoped<IHallService, HallService>();
        services.AddScoped<ISpecializationService, SpecializationService>();
        services.AddScoped<IEquipmentService, EquipmentService>();
        services.AddScoped<ITrainingEquipmentService, TrainingEquipmentService>();
        services.AddScoped<ITrainerService, TrainerService>();
        services.AddScoped<ITrainingService, TrainingService>();
        services.AddScoped<ITrainingTermService, TrainingTermService>();
        services.AddScoped<INewsItemService, NewsItemService>();
        services.AddScoped<ISystemNotificationService, SystemNotificationService>();
        services.AddScoped<IRecommendationService, RecommendationService>();
        services.AddScoped<IReportService, ReportService>();

        services.Configure<RabbitMqOptions>(configuration.GetSection("RabbitMQ"));
        services.AddSingleton<IEmailNotificationPublisher, RabbitMqEmailNotificationPublisher>();

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

        // TrainingCategory validators
        services.AddScoped<IValidator<TrainingCategoryInsertRequest>, TrainingCategoryInsertRequestValidator>();
        services.AddScoped<IValidator<TrainingCategoryUpdateRequest>, TrainingCategoryUpdateRequestValidator>();

        // DifficultyLevel validators
        services.AddScoped<IValidator<DifficultyLevelInsertRequest>, DifficultyLevelInsertRequestValidator>();
        services.AddScoped<IValidator<DifficultyLevelUpdateRequest>, DifficultyLevelUpdateRequestValidator>();

        // Hall validators
        services.AddScoped<IValidator<HallInsertRequest>, HallInsertRequestValidator>();
        services.AddScoped<IValidator<HallUpdateRequest>, HallUpdateRequestValidator>();

        // Equipment validators
        services.AddScoped<IValidator<EquipmentInsertRequest>, EquipmentInsertRequestValidator>();
        services.AddScoped<IValidator<EquipmentUpdateRequest>, EquipmentUpdateRequestValidator>();

        // TrainingEquipment validators
        services.AddScoped<IValidator<TrainingEquipmentInsertRequest>, TrainingEquipmentInsertRequestValidator>();
        services.AddScoped<IValidator<TrainingEquipmentUpdateRequest>, TrainingEquipmentUpdateRequestValidator>();

        // Specialization validators
        services.AddScoped<IValidator<SpecializationInsertRequest>, SpecializationInsertRequestValidator>();
        services.AddScoped<IValidator<SpecializationUpdateRequest>, SpecializationUpdateRequestValidator>();

        // Trainer validators
        services.AddScoped<IValidator<TrainerInsertRequest>, TrainerInsertRequestValidator>();
        services.AddScoped<IValidator<TrainerUpdateRequest>, TrainerUpdateRequestValidator>();

        // Training validators
        services.AddScoped<IValidator<TrainingInsertRequest>, TrainingInsertRequestValidator>();
        services.AddScoped<IValidator<TrainingUpdateRequest>, TrainingUpdateRequestValidator>();

        // TrainingTerm validators
        services.AddScoped<IValidator<TrainingTermInsertRequest>, TrainingTermInsertRequestValidator>();
        services.AddScoped<IValidator<TrainingTermUpdateRequest>, TrainingTermUpdateRequestValidator>();
        services.AddScoped<IValidator<TrainingTermCancelRequest>, TrainingTermCancelRequestValidator>();

        // NewsItem validators
        services.AddScoped<IValidator<NewsItemInsertRequest>, NewsItemInsertRequestValidator>();
        services.AddScoped<IValidator<NewsItemUpdateRequest>, NewsItemUpdateRequestValidator>();

        services.AddScoped<IValidator<ReservationsReportRequest>, ReservationsReportRequestValidator>();

        return services;
    }
}
