using FitBook.Model.Requests.TrainingTerms;
using FitBook.Model.Responses.TrainingTerms;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface ITrainingTermService
    : IBaseCRUDService<TrainingTermResponse, TrainingTermSearchObject, TrainingTermInsertRequest, TrainingTermUpdateRequest>
{
    Task<TrainingTermResponse> CancelAsync(int id, TrainingTermCancelRequest request, CancellationToken cancellationToken = default);
    Task<TrainingTermResponse> CompleteAsync(int id, CancellationToken cancellationToken = default);
}
