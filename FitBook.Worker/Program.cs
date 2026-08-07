using FitBook.Common.Services.Configuration;
using FitBook.Services;
using FitBook.Services.Database;
using FitBook.Services.Files;
using FitBook.Services.Interfaces;
using FitBook.Services.Messaging;
using FitBook.Worker.BackgroundServices;
using FitBook.Worker.Consumers;
using FitBook.Worker.Services;
using Microsoft.EntityFrameworkCore;

EnvConfiguration.LoadDotEnv();

var builder = Host.CreateApplicationBuilder(args);

builder.Services.Configure<RabbitMqOptions>(builder.Configuration.GetSection("RabbitMQ"));
builder.Services.Configure<FitBook.Worker.Messaging.SmtpOptions>(builder.Configuration.GetSection("SMTP"));

builder.Services.AddSingleton<DatabaseReadyGate>();
builder.Services.AddSingleton<ISmtpEmailSender, SmtpEmailSender>();
builder.Services.AddSingleton<IEmailNotificationPublisher, RabbitMqEmailNotificationPublisher>();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<FitBookDbContext>(options => options.UseSqlServer(connectionString));
builder.Services.AddScoped<IReminderService, ReminderService>();
builder.Services.AddScoped<IMembershipExpiryService, MembershipExpiryService>();
builder.Services.AddScoped<IRefreshTokenCleanupService, RefreshTokenCleanupService>();

builder.Services.Configure<FileStorageOptions>(options =>
    options.RootPath = Path.Combine(AppContext.BaseDirectory, "wwwroot"));
builder.Services.AddScoped<IUploadCleanupService, UploadCleanupService>();

builder.Services.AddHostedService<EmailNotificationConsumer>();
builder.Services.AddHostedService<ReservationReminderBackgroundService>();
builder.Services.AddHostedService<MembershipExpiryReminderBackgroundService>();
builder.Services.AddHostedService<MembershipExpiryBackgroundService>();
builder.Services.AddHostedService<RefreshTokenCleanupBackgroundService>();
builder.Services.AddHostedService<OrphanUploadCleanupBackgroundService>();

var host = builder.Build();
host.Run();
