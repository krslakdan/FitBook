import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'trainer_insert_request.g.dart';

@JsonSerializable()
class TrainerInsertRequest implements ApiRequestBody {
  TrainerInsertRequest({
    required this.firstName,
    required this.lastName,
    required this.specializationId,
    this.biography,
    this.imageUrl,
    required this.isAvailable,
    required this.isActive,
    required this.userAccountId,
  });

  final String firstName;
  final String lastName;
  final int specializationId;
  final String? biography;
  final String? imageUrl;
  final bool isAvailable;
  final bool isActive;
  final int userAccountId;

  factory TrainerInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainerInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainerInsertRequestToJson(this);
}
