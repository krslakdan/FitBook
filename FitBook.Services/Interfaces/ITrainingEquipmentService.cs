using FitBook.Model.Requests.TrainingEquipment;
using FitBook.Model.Responses.TrainingEquipment;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface ITrainingEquipmentService
    : IBaseCRUDService<TrainingEquipmentResponse, TrainingEquipmentSearchObject, TrainingEquipmentInsertRequest, TrainingEquipmentUpdateRequest>
{
}
