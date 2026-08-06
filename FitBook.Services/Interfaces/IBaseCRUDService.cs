using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IBaseCRUDService<TResponse, in TSearch, in TInsertRequest, in TUpdateRequest>
    : IBaseInsertService<TResponse, TSearch, TInsertRequest>
    where TSearch : BaseSearchObject
{
    Task<TResponse> UpdateAsync(int id, TUpdateRequest request, CancellationToken cancellationToken = default);
    Task DeleteAsync(int id, CancellationToken cancellationToken = default);
}
