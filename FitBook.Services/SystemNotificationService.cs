using FitBook.Model.Enums;
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
        if (!_currentUserService.IsAdmin())
        {
            var currentUserId = _currentUserService.GetRequiredUserId();
            query = query.Where(x => x.UserAccountId == currentUserId);
        }
        else if (search.UserAccountId.HasValue)
        {
            query = query.Where(x => x.UserAccountId == search.UserAccountId.Value);
        }
        else if (!search.NotificationType.HasValue)
        {
            query = query.Where(x => x.NotificationType != NotificationType.NewsPublished);
        }

        if (search.IsRead.HasValue)
        {
            query = query.Where(x => x.IsRead == search.IsRead.Value);
        }

        if (search.NotificationType.HasValue)
        {
            query = query.Where(x => x.NotificationType == search.NotificationType.Value);
        }

        if (search.CreatedFromUtc.HasValue)
        {
            query = query.Where(x => x.CreatedAtUtc >= search.CreatedFromUtc.Value);
        }

        if (search.CreatedToUtc.HasValue)
        {
            query = query.Where(x => x.CreatedAtUtc <= search.CreatedToUtc.Value);
        }

        return query;
    }

    protected override IQueryable<SystemNotification> ApplySearch(IQueryable<SystemNotification> query, SystemNotificationSearchObject search)
    {
        if (string.IsNullOrWhiteSpace(search.Search))
        {
            return query;
        }

        var term = search.Search.Trim().ToLowerInvariant();
        return query.Where(x =>
            x.Title.ToLower().Contains(term) ||
            x.Content.ToLower().Contains(term) ||
            x.UserAccount!.FirstName.ToLower().Contains(term) ||
            x.UserAccount.LastName.ToLower().Contains(term) ||
            (x.UserAccount.FirstName + " " + x.UserAccount.LastName).ToLower().Contains(term));
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
