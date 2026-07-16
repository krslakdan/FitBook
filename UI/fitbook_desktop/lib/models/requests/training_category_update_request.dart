import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_category_update_request.g.dart';

/// Mirrors `FitBook.Model.Requests.TrainingCategoryUpdateRequest`.
@JsonSerializable()
class TrainingCategoryUpdateRequest implements ApiRequestBody {
  TrainingCategoryUpdateRequest({required this.name, this.description, required this.isActive});

  final String name;
  final String? description;
  final bool isActive;

  factory TrainingCategoryUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingCategoryUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingCategoryUpdateRequestToJson(this);
}
