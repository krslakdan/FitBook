using FitBook.Model.Responses;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IBaseReadService<TResponse, in TSearch>
    where TSearch : BaseSearchObject
{
    Task<TResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<PageResult<TResponse>> GetAllAsync(TSearch? search = null, CancellationToken cancellationToken = default);
}
