using FitBook.Model.Requests.NewsItems;
using FitBook.Model.Responses.NewsItems;
using FitBook.Model.SearchObjects;
using FitBook.Services.Database;
using FitBook.Services.Database.Entities;
using FitBook.Services.Interfaces;
using FluentValidation;
using MapsterMapper;
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

    protected override Task BeforeInsert(NewsItemInsertRequest request, NewsItem entity, CancellationToken cancellationToken)
    {
        entity.PublishedAtUtc = DateTime.UtcNow;
        return Task.CompletedTask;
    }

    protected override IOrderedQueryable<NewsItem> ApplyOrdering(IQueryable<NewsItem> query, NewsItemSearchObject search)
    {
        return query.OrderByDescending(x => x.PublishedAtUtc);
    }
}
