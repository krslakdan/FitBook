using FitBook.Model.Enums;

namespace FitBook.Model.SearchObjects;

public class TrainingTermSearchObject : BaseSearchObject
{
    public int? TrainingId { get; set; }
    public int? TrainerId { get; set; }
    public int? HallId { get; set; }
    public TrainingTermStatus? Status { get; set; }
    public DateTime? StartFromUtc { get; set; }
    public DateTime? StartToUtc { get; set; }
    public bool? IsActive { get; set; }
}
