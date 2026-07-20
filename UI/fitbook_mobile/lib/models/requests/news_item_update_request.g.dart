// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_item_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsItemUpdateRequest _$NewsItemUpdateRequestFromJson(
  Map<String, dynamic> json,
) => NewsItemUpdateRequest(
  title: json['title'] as String,
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$NewsItemUpdateRequestToJson(
  NewsItemUpdateRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'imageUrl': instance.imageUrl,
  'isActive': instance.isActive,
};
