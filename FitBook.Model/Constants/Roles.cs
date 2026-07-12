namespace FitBook.Model.Constants;

public static class Roles
{
    public const string Admin = "Admin";
    public const string Trainer = "Trainer";
    public const string User = "User";

    public static string[] All => [Admin, Trainer, User];
}
