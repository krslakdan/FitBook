using System.Text.Json;
using FitBook.Model.Messages;
using FitBook.Worker.Messaging;
using FitBook.Worker.Services;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace FitBook.Worker.Consumers;

public sealed class EmailNotificationConsumer : BackgroundService
{
    private const int MaxRetryAttempts = 4;

    private readonly RabbitMqOptions _options;
    private readonly ISmtpEmailSender _emailSender;
    private readonly ILogger<EmailNotificationConsumer> _logger;
    private readonly object _channelLock = new();
    private IConnection? _connection;
    private IModel? _channel;

    public EmailNotificationConsumer(
        IOptions<RabbitMqOptions> options,
        ISmtpEmailSender emailSender,
        ILogger<EmailNotificationConsumer> logger)
    {
        _options = options.Value;
        _emailSender = emailSender;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = _options.Host,
            Port = _options.Port,
            UserName = _options.Username,
            Password = _options.Password,
            DispatchConsumersAsync = true,
            AutomaticRecoveryEnabled = true,
        };

        await ConnectWithRetryAsync(factory, stoppingToken);

        if (_channel is null)
        {
            return;
        }

        var consumer = new AsyncEventingBasicConsumer(_channel);
        consumer.Received += async (_, eventArgs) => await HandleMessageAsync(eventArgs, stoppingToken);

        _channel.BasicConsume(queue: _options.NotificationQueue, autoAck: false, consumer: consumer);

        _logger.LogInformation("EmailNotificationConsumer started, listening on queue '{Queue}'.", _options.NotificationQueue);

        try
        {
            await Task.Delay(Timeout.Infinite, stoppingToken);
        }
        catch (OperationCanceledException)
        {
        }
    }

    private async Task ConnectWithRetryAsync(ConnectionFactory factory, CancellationToken stoppingToken)
    {
        var delay = TimeSpan.FromSeconds(1);
        var maxDelay = TimeSpan.FromSeconds(30);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                _connection = factory.CreateConnection();
                _channel = _connection.CreateModel();
                _channel.QueueDeclare(queue: _options.NotificationQueue, durable: true, exclusive: false, autoDelete: false, arguments: null);
                _channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);
                return;
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Failed to connect to RabbitMQ at {Host}:{Port}. Retrying in {Delay}.",
                    _options.Host,
                    _options.Port,
                    delay);

                try
                {
                    await Task.Delay(delay, stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    return;
                }

                delay = TimeSpan.FromSeconds(Math.Min(delay.TotalSeconds * 2, maxDelay.TotalSeconds));
            }
        }
    }

    private async Task HandleMessageAsync(BasicDeliverEventArgs eventArgs, CancellationToken stoppingToken)
    {
        EmailNotificationMessage? message;
        try
        {
            message = JsonSerializer.Deserialize<EmailNotificationMessage>(eventArgs.Body.Span);
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex, "Received an unparseable email notification message. Discarding.");
            Ack(eventArgs.DeliveryTag);
            return;
        }

        if (message is null)
        {
            _logger.LogWarning("Received a null email notification message. Discarding.");
            Ack(eventArgs.DeliveryTag);
            return;
        }

        try
        {
            await _emailSender.SendAsync(message, stoppingToken);
            Ack(eventArgs.DeliveryTag);
        }
        catch (Exception ex)
        {
            Ack(eventArgs.DeliveryTag);
            await HandleFailureAsync(message, ex, stoppingToken);
        }
    }

    private async Task HandleFailureAsync(EmailNotificationMessage message, Exception ex, CancellationToken stoppingToken)
    {
        if (message.RetryCount >= MaxRetryAttempts)
        {
            _logger.LogError(
                ex,
                "Failed to send email notification to {ToEmail} after {AttemptCount} attempt(s). Giving up; message will be dropped.",
                message.ToEmail,
                message.RetryCount + 1);
            return;
        }

        var delay = TimeSpan.FromSeconds(Math.Pow(2, message.RetryCount));

        _logger.LogError(
            ex,
            "Failed to send email notification to {ToEmail} (attempt {AttemptCount}/{MaxAttemptCount}). Retrying in {Delay}.",
            message.ToEmail,
            message.RetryCount + 1,
            MaxRetryAttempts + 1,
            delay);

        try
        {
            await Task.Delay(delay, stoppingToken);
        }
        catch (OperationCanceledException)
        {
            return;
        }

        message.RetryCount++;
        Republish(message);
    }

    private void Ack(ulong deliveryTag)
    {
        lock (_channelLock)
        {
            _channel!.BasicAck(deliveryTag, multiple: false);
        }
    }

    private void Republish(EmailNotificationMessage message)
    {
        try
        {
            var body = JsonSerializer.SerializeToUtf8Bytes(message);

            lock (_channelLock)
            {
                var properties = _channel!.CreateBasicProperties();
                properties.Persistent = true;
                properties.ContentType = "application/json";

                _channel.BasicPublish(exchange: string.Empty, routingKey: _options.NotificationQueue, basicProperties: properties, body: body);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to republish email notification for retry to {ToEmail}.", message.ToEmail);
        }
    }

    public override void Dispose()
    {
        _channel?.Close();
        _channel?.Dispose();
        _connection?.Close();
        _connection?.Dispose();
        base.Dispose();
        GC.SuppressFinalize(this);
    }
}
