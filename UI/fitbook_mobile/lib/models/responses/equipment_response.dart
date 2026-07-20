import 'package:json_annotation/json_annotation.dart';

part 'equipment_response.g.dart';

@JsonSerializable()
class EquipmentResponse {
  EquipmentResponse({
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

  factory EquipmentResponse.fromJson(Map<String, dynamic> json) =>
      _$EquipmentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentResponseToJson(this);
}
