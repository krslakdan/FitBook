namespace FitBook.Model.SearchObjects;

public class RecommendationSearchObject : BaseSearchObject
{
    public const int MaxRecommendationsPageSize = 20;
    public const int DefaultRecommendationsPageSize = 5;

    public RecommendationSearchObject()
    {
        PageSize = DefaultRecommendationsPageSize;
    }
}
