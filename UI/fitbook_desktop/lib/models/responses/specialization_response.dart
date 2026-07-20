import 'package:json_annotation/json_annotation.dart';

part 'specialization_response.g.dart';

@JsonSerializable()
class SpecializationResponse {
  SpecializationResponse({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory SpecializationResponse.fromJson(Map<String, dynamic> json) =>
      _$SpecializationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SpecializationResponseToJson(this);
}
