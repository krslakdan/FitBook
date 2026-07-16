using FitBook.Model.Exceptions;
using FitBook.Model.Responses.SystemNotifications;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class SystemNotificationService
    : BaseReadService<SystemNotification, SystemNotificationResponse, SystemNotificationSearchObject>,
      ISystemNotificationService
{
    private readonly ICurrentUserService _currentUserService;

    public SystemNotificationService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        ICurrentUserService currentUserService)
        : base(dbContext, mapper, loggerFactory)
    {
        _currentUserService = currentUserService;
    }

    protected override IQueryable<SystemNotification> ApplyFilter(IQueryable<SystemNotification> query, SystemNotificationSearchObject search)
    {
        var currentUserId = _currentUserService.GetRequiredUserId();
        query = query.Where(x => x.UserAccountId == currentUserId);

        if (search.IsRead.HasValue)
        {
            query = query.Where(x => x.IsRead == search.IsRead.Value);
        }

        if (search.NotificationType.HasValue)
        {
            query = query.Where(x => x.NotificationType == search.NotificationType.Value);
        }

        return query;
    }

    public async Task MarkAsReadAsync(int id, CancellationToken cancellationToken = default)
    {
        var currentUserId = _currentUserService.GetRequiredUserId();

        var notification = await _dbContext.SystemNotifications
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

        if (notification == null)
        {
            throw new NotFoundException($"Notifikacija sa ID {id} nije pronađena.");
        }

        if (notification.UserAccountId != currentUserId)
        {
            throw new BusinessException("Nemate pravo označiti ovu notifikaciju kao pročitanu.");
        }

        if (!notification.IsRead)
        {
            notification.IsRead = true;
            notification.ReadAtUtc = DateTime.UtcNow;
            notification.UpdatedAtUtc = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync(cancellationToken);
        }
    }
}
