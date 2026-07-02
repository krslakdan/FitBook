namespace FitBook.Services.Database.Entities;

public interface ISoftDeletable
{
    bool IsDeleted { get; set; }
}
