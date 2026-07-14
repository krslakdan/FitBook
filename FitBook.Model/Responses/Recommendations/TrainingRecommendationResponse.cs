namespace FitBook.Model.Responses.Recommendations;

public class TrainingRecommendationResponse
{
    public int TrainingId { get; set; }
    public string TrainingName { get; set; } = string.Empty;
    public string TrainingCategoryName { get; set; } = string.Empty;
    public int DurationMinutes { get; set; }
    public decimal Score { get; set; }
    public string Explanation { get; set; } = string.Empty;
}
