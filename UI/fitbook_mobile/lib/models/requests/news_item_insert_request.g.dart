// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_item_insert_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsItemInsertRequest _$NewsItemInsertRequestFromJson(
  Map<String, dynamic> json,
) => NewsItemInsertRequest(
  title: json['title'] as String,
  content: json['content'] as String,
  imageUrl: json['imageUrl'] as String,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$NewsItemInsertRequestToJson(
  NewsItemInsertRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'imageUrl': instance.imageUrl,
  'isActive': instance.isActive,
};
