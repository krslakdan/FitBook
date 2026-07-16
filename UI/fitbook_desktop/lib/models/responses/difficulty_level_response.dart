import 'package:json_annotation/json_annotation.dart';

part 'difficulty_level_response.g.dart';

/// Mirrors `FitBook.Model.Responses.DifficultyLevelResponse`.
@JsonSerializable()
class DifficultyLevelResponse {
  DifficultyLevelResponse({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String name;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory DifficultyLevelResponse.fromJson(Map<String, dynamic> json) =>
      _$DifficultyLevelResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DifficultyLevelResponseToJson(this);
}
