using System.Text.Json;
using FitBook.Model.Messages;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;

namespace FitBook.Services.Messaging;

public sealed class RabbitMqEmailNotificationPublisher : IEmailNotificationPublisher, IDisposable
{
    private static readonly TimeSpan ConfirmTimeout = TimeSpan.FromSeconds(5);

    private readonly RabbitMqOptions _options;
    private readonly ILogger<RabbitMqEmailNotificationPublisher> _logger;
    private readonly object _connectionLock = new();
    private IConnection? _connection;
    private IModel? _channel;

    public RabbitMqEmailNotificationPublisher(IOptions<RabbitMqOptions> options, ILogger<RabbitMqEmailNotificationPublisher> logger)
    {
        _options = options.Value;
        _logger = logger;
    }

    public Task PublishAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default)
    {
        try
        {
            Publish(message);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to publish email notification to RabbitMQ for {ToEmail}. Continuing without this notification.", message.ToEmail);
        }

        return Task.CompletedTask;
    }

    public Task PublishOrThrowAsync(EmailNotificationMessage message, CancellationToken cancellationToken = default)
    {
        Publish(message, waitForConfirmation: true);
        return Task.CompletedTask;
    }

    private void Publish(EmailNotificationMessage message, bool waitForConfirmation = false)
    {
        var body = JsonSerializer.SerializeToUtf8Bytes(message);

        lock (_connectionLock)
        {
            var channel = GetOrCreateChannel();

            var properties = channel.CreateBasicProperties();
            properties.Persistent = true;
            properties.ContentType = "application/json";

            channel.BasicPublish(exchange: string.Empty, routingKey: _options.NotificationQueue, basicProperties: properties, body: body);

            if (waitForConfirmation)
            {
                channel.WaitForConfirmsOrDie(ConfirmTimeout);
            }
        }

        _logger.LogInformation("Published email notification to queue {Queue} for {ToEmail}.", _options.NotificationQueue, message.ToEmail);
    }

    private IModel GetOrCreateChannel()
    {
        if (_channel is { IsOpen: true })
        {
            return _channel;
        }

        _channel?.Dispose();
        _connection?.Dispose();
        _channel = null;
        _connection = null;

        var factory = new ConnectionFactory
        {
            HostName = _options.Host,
            Port = _options.Port,
            UserName = _options.Username,
            Password = _options.Password,
            AutomaticRecoveryEnabled = true,
        };

        var connection = factory.CreateConnection();
        var channel = connection.CreateModel();
        channel.QueueDeclare(queue: _options.NotificationQueue, durable: true, exclusive: false, autoDelete: false, arguments: null);
        channel.ConfirmSelect();

        _connection = connection;
        _channel = channel;

        return channel;
    }

    public void Dispose()
    {
        _channel?.Close();
        _channel?.Dispose();
        _connection?.Close();
        _connection?.Dispose();
    }
}
