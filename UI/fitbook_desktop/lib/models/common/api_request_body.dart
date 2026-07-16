/// Implemented by every generated request model. Lets [BaseProvider]'s
/// `apiPost`/`apiPut` (and [BaseCrudProvider]'s `insert`/`update`) accept a
/// request payload without falling back to `dynamic` or relying on
/// `dart:convert`'s implicit `toJson()` dispatch.
abstract interface class ApiRequestBody {
  Map<String, dynamic> toJson();
}
