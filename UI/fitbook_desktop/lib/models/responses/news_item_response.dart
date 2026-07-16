import 'package:json_annotation/json_annotation.dart';

part 'news_item_response.g.dart';

@JsonSerializable()
class NewsItemResponse {
  NewsItemResponse({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.publishedAtUtc,
    required this.isActive,
    required this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final DateTime publishedAtUtc;
  final bool isActive;
  final DateTime createdAtUtc;
  final DateTime? updatedAtUtc;

  factory NewsItemResponse.fromJson(Map<String, dynamic> json) =>
      _$NewsItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NewsItemResponseToJson(this);
}
