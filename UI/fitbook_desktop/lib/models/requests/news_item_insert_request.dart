import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'news_item_insert_request.g.dart';

/// Mirrors `FitBook.Model.Requests.NewsItemInsertRequest`.
@JsonSerializable()
class NewsItemInsertRequest implements ApiRequestBody {
  NewsItemInsertRequest({
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.isActive,
  });

  final String title;
  final String content;
  final String imageUrl;
  final bool isActive;

  factory NewsItemInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$NewsItemInsertRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NewsItemInsertRequestToJson(this);
}
