import '../models/responses/system_notification_response.dart';
import 'base_read_provider.dart';

class SystemNotificationProvider extends BaseReadProvider<SystemNotificationResponse> {
  SystemNotificationProvider() : super('SystemNotifications');

  @override
  SystemNotificationResponse fromJson(Map<String, dynamic> json) =>
      SystemNotificationResponse.fromJson(json);
}
