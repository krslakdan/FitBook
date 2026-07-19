import '../common/base_search_object.dart';
import '../enums/notification_type.dart';

class SystemNotificationSearchObject extends BaseSearchObject {
  const SystemNotificationSearchObject({
    super.page,
    super.pageSize,
    super.search,
    super.includeTotalCount,
    this.isRead,
    this.notificationType,
    this.userAccountId,
    this.createdFromUtc,
    this.createdToUtc,
  });

  final bool? isRead;
  final NotificationType? notificationType;
  final int? userAccountId;
  final DateTime? createdFromUtc;
  final DateTime? createdToUtc;

  @override
  Map<String, dynamic> toQueryParameters() {
    final params = super.toQueryParameters();
    if (isRead != null) params['isRead'] = isRead;
    if (notificationType != null) {
      params['notificationType'] = notificationType!.value;
    }
    if (userAccountId != null) params['userAccountId'] = userAccountId;
    if (createdFromUtc != null) {
      params['createdFromUtc'] = createdFromUtc!.toIso8601String();
    }
    if (createdToUtc != null) {
      params['createdToUtc'] = createdToUtc!.toIso8601String();
    }
    return params;
  }
}
