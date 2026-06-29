namespace FitBook.Model.Responses;

public class PageResult<T>
{
    public List<T> Items { get; set; } = [];
    public int? TotalCount { get; set; }
}
