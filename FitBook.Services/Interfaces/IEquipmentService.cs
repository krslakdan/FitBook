using FitBook.Model.Requests.Equipment;
using FitBook.Model.Responses.Equipment;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IEquipmentService
    : IBaseCRUDService<EquipmentResponse, EquipmentSearchObject, EquipmentInsertRequest, EquipmentUpdateRequest>
{
}
