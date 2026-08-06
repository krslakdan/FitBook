using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IBaseInsertService<TResponse, in TSearch, in TInsertRequest>
    : IBaseReadService<TResponse, TSearch>
    where TSearch : BaseSearchObject
{
    Task<TResponse> InsertAsync(TInsertRequest request, CancellationToken cancellationToken = default);
}
