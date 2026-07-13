using FitBook.Model.Requests.TrainingCategories;
using FitBook.Model.Responses.TrainingCategories;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface ITrainingCategoryService
    : IBaseCRUDService<TrainingCategoryResponse, TrainingCategorySearchObject, TrainingCategoryInsertRequest, TrainingCategoryUpdateRequest>
{
}
