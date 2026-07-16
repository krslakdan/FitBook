import 'package:json_annotation/json_annotation.dart';

part 'hall_response.g.dart';

/// Mirrors `FitBook.Model.Responses.HallResponse`.
@JsonSerializable()
class HallResponse {
  HallResponse({
    required this.id,
    required this.name,
    required this.capacity,
    this.locationDescription,
    required this.isActive,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String name;
  final int capacity;
  final String? locationDescription;
  final bool isActive;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory HallResponse.fromJson(Map<String, dynamic> json) => _$HallResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HallResponseToJson(this);
}
