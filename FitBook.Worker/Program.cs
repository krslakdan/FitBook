using FitBook.Common.Services.Configuration;
using FitBook.Services;
using FitBook.Services.Database;
using FitBook.Services.Interfaces;
using FitBook.Services.Messaging;
using FitBook.Worker.BackgroundServices;
using FitBook.Worker.Consumers;
using FitBook.Worker.Services;
using Microsoft.EntityFrameworkCore;

EnvConfiguration.LoadDotEnv();

var builder = Host.CreateApplicationBuilder(args);

builder.Services.Configure<FitBook.Worker.Messaging.RabbitMqOptions>(builder.Configuration.GetSection("RabbitMQ"));
builder.Services.Configure<FitBook.Services.Messaging.RabbitMqOptions>(builder.Configuration.GetSection("RabbitMQ"));
builder.Services.Configure<FitBook.Worker.Messaging.SmtpOptions>(builder.Configuration.GetSection("SMTP"));

builder.Services.AddSingleton<ISmtpEmailSender, SmtpEmailSender>();
builder.Services.AddSingleton<IEmailNotificationPublisher, RabbitMqEmailNotificationPublisher>();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<FitBookDbContext>(options => options.UseSqlServer(connectionString));
builder.Services.AddScoped<IReminderService, ReminderService>();

builder.Services.AddHostedService<EmailNotificationConsumer>();
builder.Services.AddHostedService<ReservationReminderBackgroundService>();
builder.Services.AddHostedService<MembershipExpiryReminderBackgroundService>();

var host = builder.Build();
host.Run();
