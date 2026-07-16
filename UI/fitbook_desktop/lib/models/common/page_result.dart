import 'package:json_annotation/json_annotation.dart';

part 'page_result.g.dart';

/// Mirrors `FitBook.Model.Responses.PageResult<T>` — the shape every list
/// endpoint (`BaseReadController.GetAll`) returns.
@JsonSerializable(genericArgumentFactories: true)
class PageResult<T> {
  PageResult({
    required this.page,
    required this.pageSize,
    required this.items,
    this.totalCount,
    this.totalPages,
  });

  final int page;
  final int pageSize;
  final int? totalCount;
  final int? totalPages;
  final List<T> items;

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PageResultFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PageResultToJson(this, toJsonT);
}
