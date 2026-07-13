using FitBook.Model.Requests.Trainers;
using FitBook.Model.Responses.Trainers;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface ITrainerService
    : IBaseCRUDService<TrainerResponse, TrainerSearchObject, TrainerInsertRequest, TrainerUpdateRequest>
{
}
