using FitBook.Model.Requests.Specializations;
using FitBook.Model.Responses.Specializations;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface ISpecializationService
    : IBaseCRUDService<SpecializationResponse, SpecializationSearchObject, SpecializationInsertRequest, SpecializationUpdateRequest>
{
}
