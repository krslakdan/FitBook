using FitBook.Model.Requests.Trainings;
using FitBook.Model.Responses.Trainings;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface ITrainingService
    : IBaseCRUDService<TrainingResponse, TrainingSearchObject, TrainingInsertRequest, TrainingUpdateRequest>
{
}
