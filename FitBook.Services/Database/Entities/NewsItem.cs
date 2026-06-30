namespace FitBook.Services.Database.Entities;

public class NewsItem
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public DateTime PublishedAtUtc { get; set; }
    public bool IsActive { get; set; }
}
