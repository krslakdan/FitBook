// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageResult<T> _$PageResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PageResult<T>(
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
  totalPages: (json['totalPages'] as num?)?.toInt(),
);

Map<String, dynamic> _$PageResultToJson<T>(
  PageResult<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalCount': instance.totalCount,
  'totalPages': instance.totalPages,
  'items': instance.items.map(toJsonT).toList(),
};
