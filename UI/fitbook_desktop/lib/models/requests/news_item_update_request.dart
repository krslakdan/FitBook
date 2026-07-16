import 'package:json_annotation/json_annotation.dart';

import '../common/api_request_body.dart';

part 'news_item_update_request.g.dart';

/// Mirrors `FitBook.Model.Requests.NewsItemUpdateRequest`.
@JsonSerializable()
class NewsItemUpdateRequest implements ApiRequestBody {
  NewsItemUpdateRequest({
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.isActive,
  });

  final String title;
  final String content;
  final String imageUrl;
  final bool isActive;

  factory NewsItemUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$NewsItemUpdateRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NewsItemUpdateRequestToJson(this);
}
