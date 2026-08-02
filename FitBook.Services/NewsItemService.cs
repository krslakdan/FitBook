using FitBook.Model.Constants;
using FitBook.Model.Enums;
using FitBook.Model.Requests.NewsItems;
using FitBook.Model.Responses.NewsItems;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace FitBook.Services;

public class NewsItemService
    : BaseCRUDService<NewsItem, NewsItemResponse, NewsItemSearchObject, NewsItemInsertRequest, NewsItemUpdateRequest>,
      INewsItemService
{
    public NewsItemService(
        FitBookDbContext dbContext,
        IMapper mapper,
        ILoggerFactory loggerFactory,
        IValidator<NewsItemInsertRequest> insertValidator,
        IValidator<NewsItemUpdateRequest> updateValidator)
        : base(dbContext, mapper, loggerFactory, insertValidator, updateValidator)
    {
    }

    protected override IQueryable<NewsItem> ApplyFilter(IQueryable<NewsItem> query, NewsItemSearchObject search)
    {
        if (search.IsActive.HasValue)
        {
            query = query.Where(x => x.IsActive == search.IsActive.Value);
        }

        return query;
    }

    protected override IQueryable<NewsItem> ApplySearch(IQueryable<NewsItem> query, NewsItemSearchObject search)
    {
        if (!string.IsNullOrWhiteSpace(search.Search))
        {
            var term = search.Search.Trim().ToLowerInvariant();
            query = query.Where(x =>
                x.Title.ToLower().Contains(term) ||
                x.Content.ToLower().Contains(term));
        }

        return query;
    }

    protected override async Task BeforeInsert(NewsItemInsertRequest request, NewsItem entity, CancellationToken cancellationToken)
    {
        entity.PublishedAtUtc = DateTime.UtcNow;

        if (entity.IsActive)
        {
            await AddNewsPublishedNotificationsAsync(entity.Title, cancellationToken);
        }
    }

    protected override async Task BeforeUpdate(int id, NewsItemUpdateRequest request, NewsItem entity, CancellationToken cancellationToken)
    {
        if (!entity.IsActive && request.IsActive)
        {
            await AddNewsPublishedNotificationsAsync(request.Title, cancellationToken);
        }
    }

    private async Task AddNewsPublishedNotificationsAsync(string title, CancellationToken cancellationToken)
    {
        var recipientIds = await _dbContext.UserAccounts
            .Where(x => x.Role == Roles.User && x.IsActive && !x.IsDeleted)
            .Select(x => x.Id)
            .ToListAsync(cancellationToken);

        if (recipientIds.Count == 0)
        {
            return;
        }

        var createdAtUtc = DateTime.UtcNow;
        foreach (var userAccountId in recipientIds)
        {
            _dbContext.SystemNotifications.Add(new SystemNotification
            {
                UserAccountId = userAccountId,
                NotificationType = NotificationType.NewsPublished,
                Title = "Nova obavijest",
                Content = $"Objavljena je nova obavijest: {title}",
                IsRead = false,
                CreatedAtUtc = createdAtUtc,
            });
        }
    }

    protected override IOrderedQueryable<NewsItem> ApplyOrdering(IQueryable<NewsItem> query, NewsItemSearchObject search)
    {
        return query.OrderByDescending(x => x.PublishedAtUtc);
    }
}
