import '../models/responses/news_item_response.dart';
import 'base_crud_provider.dart';

class NewsItemProvider extends BaseCrudProvider<NewsItemResponse> {
  NewsItemProvider() : super('NewsItems');

  @override
  NewsItemResponse fromJson(Map<String, dynamic> json) => NewsItemResponse.fromJson(json);
}
