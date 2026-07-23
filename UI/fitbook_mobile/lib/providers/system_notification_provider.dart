import 'dart:async';

import '../models/responses/system_notification_response.dart';
import '../models/search_objects/system_notification_search_object.dart';
import '../utils/api_client_exception.dart';
import 'base_read_provider.dart';

class SystemNotificationProvider extends BaseReadProvider<SystemNotificationResponse> {
  SystemNotificationProvider() : super('SystemNotifications');

  @override
  SystemNotificationResponse fromJson(Map<String, dynamic> json) =>
      SystemNotificationResponse.fromJson(json);

  final List<SystemNotificationResponse> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  Timer? _pollTimer;
  int? _userAccountId;

  List<SystemNotificationResponse> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnread => _unreadCount > 0;

  void setUserScope(int? userAccountId) {
    if (_userAccountId == userAccountId) return;
    _userAccountId = userAccountId;
    _notifications.clear();
    _unreadCount = 0;
  }

  Future<void> loadNotifications({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final result = await get(
        filter: SystemNotificationSearchObject(
          page: 1,
          pageSize: 100,
          includeTotalCount: true,
          userAccountId: _userAccountId,
        ),
      );
      _notifications
        ..clear()
        ..addAll(result.items);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _error = null;
    } on ApiClientException catch (e) {
      if (!silent) _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final result = await get(
        filter: SystemNotificationSearchObject(
          page: 1,
          pageSize: 1,
          isRead: false,
          includeTotalCount: true,
          userAccountId: _userAccountId,
        ),
      );
      _unreadCount = result.totalCount ?? 0;
      notifyListeners();
    } on ApiClientException {
      return;
    }
  }

  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    await apiPut('SystemNotifications/$id/read');

    _notifications[index] = _notifications[index].copyWith(
      isRead: true,
      readAtUtc: DateTime.now().toUtc(),
    );
    if (_unreadCount > 0) _unreadCount--;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    final unreadIds = _notifications.where((n) => !n.isRead).map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;

    for (final id in unreadIds) {
      await apiPut('SystemNotifications/$id/read');
    }

    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(
          isRead: true,
          readAtUtc: DateTime.now().toUtc(),
        );
      }
    }
    _unreadCount = 0;
    notifyListeners();
  }

  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => refreshUnreadCount());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
