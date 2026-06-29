namespace FitBook.Model.Messages;

public sealed record NotificationMessage(
    int UserId,
    string Title,
    string Body,
    DateTime CreatedAtUtc);
