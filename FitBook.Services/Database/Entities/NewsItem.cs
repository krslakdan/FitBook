namespace FitBook.Services.Database.Entities;

public class NewsItem : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public DateTime PublishedAtUtc { get; set; }
    public bool IsActive { get; set; }
}
