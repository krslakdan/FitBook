import 'package:json_annotation/json_annotation.dart';

part 'user_account_response.g.dart';

/// Mirrors `FitBook.Model.Responses.UserAccounts.UserAccountResponse`.
/// Note: intentionally has no password/hash field — the backend never
/// serializes it.
@JsonSerializable()
class UserAccountResponse {
  UserAccountResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.role,
    this.profileImageUrl,
    required this.isActive,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String username;
  final String role;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory UserAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$UserAccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UserAccountResponseToJson(this);
}
