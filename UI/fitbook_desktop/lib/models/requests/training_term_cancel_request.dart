import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'training_term_cancel_request.g.dart';

/// Mirrors `FitBook.Model.Requests.TrainingTermCancelRequest`.
@JsonSerializable()
class TrainingTermCancelRequest implements ApiRequestBody {
  TrainingTermCancelRequest({this.reason});

  final String? reason;

  factory TrainingTermCancelRequest.fromJson(Map<String, dynamic> json) =>
      _$TrainingTermCancelRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrainingTermCancelRequestToJson(this);
}
