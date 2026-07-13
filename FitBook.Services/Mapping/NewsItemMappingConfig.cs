using FitBook.Model.Requests.NewsItems;
using FitBook.Model.Responses.NewsItems;
using FitBook.Services.Database.Entities;
using Mapster;

namespace FitBook.Services.Mapping;

public class NewsItemMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<NewsItem, NewsItemResponse>();

#pragma warning disable CS8603
        config.NewConfig<NewsItemInsertRequest, NewsItem>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.PublishedAtUtc)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);

        config.NewConfig<NewsItemUpdateRequest, NewsItem>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.PublishedAtUtc)
            .Ignore(dest => dest.CreatedAtUtc)
            .Ignore(dest => dest.UpdatedAtUtc);
#pragma warning restore CS8603
    }
}
