using FitBook.Model.Requests.Halls;
using FitBook.Model.Responses.Halls;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IHallService
    : IBaseCRUDService<HallResponse, HallSearchObject, HallInsertRequest, HallUpdateRequest>
{
}
