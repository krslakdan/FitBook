class AppRoles {
  AppRoles._();

  static const String admin = 'Admin';
  static const String trainer = 'Trainer';
  static const String user = 'User';

  static const List<String> all = [admin, trainer, user];

  static String displayName(String role) => switch (role) {
    admin => 'Administrator',
    trainer => 'Trener',
    user => 'Korisnik',
    _ => role,
  };
}
