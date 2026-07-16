import 'package:json_annotation/json_annotation.dart';

part 'trainer_response.g.dart';

/// Mirrors `FitBook.Model.Responses.TrainerResponse`.
@JsonSerializable()
class TrainerResponse {
  TrainerResponse({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.specialization,
    this.biography,
    this.imageUrl,
    required this.isAvailable,
    required this.isActive,
    required this.userAccountId,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String specialization;
  final String? biography;
  final String? imageUrl;
  final bool isAvailable;
  final bool isActive;
  final int userAccountId;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory TrainerResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainerResponseToJson(this);
}
