using FitBook.Model.Requests.DifficultyLevels;
using FitBook.Model.Responses.DifficultyLevels;
using FitBook.Model.SearchObjects;

namespace FitBook.Services.Interfaces;

public interface IDifficultyLevelService
    : IBaseCRUDService<DifficultyLevelResponse, DifficultyLevelSearchObject, DifficultyLevelInsertRequest, DifficultyLevelUpdateRequest>
{
}
