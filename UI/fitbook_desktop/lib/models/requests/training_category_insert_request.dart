import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_category_insert_request.g.dart';

@JsonSerializable()
class TrainingCategoryInsertRequest implements ApiRequestBody {
  TrainingCategoryInsertRequest({required this.name, this.description, required this.isActive});

  final String name;
  final String? description;
  final bool isActive;

  factory TrainingCategoryInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingCategoryInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingCategoryInsertRequestToJson(this);
}
