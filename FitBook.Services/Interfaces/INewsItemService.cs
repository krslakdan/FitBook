using FitBook.Model.Requests.NewsItems;
using FitBook.Model.Responses.NewsItems;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface INewsItemService
    : IBaseCRUDService<NewsItemResponse, NewsItemSearchObject, NewsItemInsertRequest, NewsItemUpdateRequest>
{
}
