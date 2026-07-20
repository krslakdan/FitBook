import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'trainer_update_request.g.dart';

@JsonSerializable()
class TrainerUpdateRequest implements ApiRequestBody {
  TrainerUpdateRequest({
    required this.firstName,
    required this.lastName,
    required this.specializationId,
    this.biography,
    this.imageUrl,
    required this.isAvailable,
    required this.isActive,
  });

  final String firstName;
  final String lastName;
  final int specializationId;
  final String? biography;
  final String? imageUrl;
  final bool isAvailable;
  final bool isActive;

  factory TrainerUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainerUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainerUpdateRequestToJson(this);
}
