using FitBook.Model.Enums;

namespace FitBook.Model.SearchObjects;

public class ReservationSearchObject : BaseSearchObject
{
    public int? UserAccountId { get; set; }
    public int? TrainingTermId { get; set; }
    public ReservationStatus? Status { get; set; }
    public DateTime? ReservedFromUtc { get; set; }
    public DateTime? ReservedToUtc { get; set; }
}
