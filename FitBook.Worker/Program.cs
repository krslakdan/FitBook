using FitBook.Common.Services.Configuration;
using FitBook.Worker.Consumers;
using FitBook.Worker.Messaging;
using FitBook.Worker.Services;

EnvConfiguration.LoadDotEnv();

var builder = Host.CreateApplicationBuilder(args);

builder.Services.Configure<RabbitMqOptions>(builder.Configuration.GetSection("RabbitMQ"));
builder.Services.Configure<SmtpOptions>(builder.Configuration.GetSection("SMTP"));

builder.Services.AddSingleton<ISmtpEmailSender, SmtpEmailSender>();
builder.Services.AddHostedService<EmailNotificationConsumer>();

var host = builder.Build();
host.Run();
