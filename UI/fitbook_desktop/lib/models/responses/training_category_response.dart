import 'package:json_annotation/json_annotation.dart';

part 'training_category_response.g.dart';

@JsonSerializable()
class TrainingCategoryResponse {
  TrainingCategoryResponse({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory TrainingCategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$TrainingCategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingCategoryResponseToJson(this);
}
