// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsItemResponse _$NewsItemResponseFromJson(Map<String, dynamic> json) =>
    NewsItemResponse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String,
      publishedAtUtc: DateTime.parse(json['publishedAtUtc'] as String),
      isActive: json['isActive'] as bool,
      createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
      updatedAtUtc: json['updatedAtUtc'] == null
          ? null
          : DateTime.parse(json['updatedAtUtc'] as String),
    );

Map<String, dynamic> _$NewsItemResponseToJson(NewsItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'publishedAtUtc': instance.publishedAtUtc.toIso8601String(),
      'isActive': instance.isActive,
      'createdAtUtc': instance.createdAtUtc.toIso8601String(),
      'updatedAtUtc': instance.updatedAtUtc?.toIso8601String(),
    };
