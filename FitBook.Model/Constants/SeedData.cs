namespace FitBook.Model.Constants;

public static class SeedData
{
    public const string TestPassword = "test";

    /// <summary>
    /// BCrypt hash of <see cref="TestPassword"/>. Used by HasData seed and any runtime seeder.
    /// </summary>
    public const string TestPasswordHash = "$2a$11$absRakK74SEnr3k6jdjqHeTmEa7SE2m2/0J09n4aSg/kLY1jGVW46";
}
