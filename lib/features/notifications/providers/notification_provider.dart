import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracky_mobile/core/models/api_response.dart';
import 'package:tracky_mobile/features/notifications/models/notification_model.dart';
import 'package:tracky_mobile/features/notifications/services/notification_api_service.dart';

final notificationsProvider =
    NotifierProvider<
      NotificationsNotifier,
      ApiResponse<List<NotificationModel>>
    >(NotificationsNotifier.new);

class NotificationsNotifier
    extends Notifier<ApiResponse<List<NotificationModel>>> {
  late final NotificationApiService _notificationApiService;

  @override
  ApiResponse<List<NotificationModel>> build() {
    _notificationApiService = ref.watch(notificationApiServiceProvider);
    return ApiResponse.init();
  }

  Future<void> loadNotifications() async {
    state = ApiResponse(status: Status.loading, isLoading: true);
    final response = await _notificationApiService.fetchNotifications();
    state = response;
  }

  Future<void> markAsRead(String notificationId) async {
    // Optimistic update
    final currentState = state;
    if (currentState.status == Status.completed && currentState.data != null) {
      final updatedList = currentState.data!.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(read: true);
        }
        return notification;
      }).toList();
      state = ApiResponse.completed(updatedList);
    }

    // Call API
    final response = await _notificationApiService.markAsRead(notificationId);

    // Revert if error (optional, handling simple for now)
    if (response.status == Status.error) {
      // Ideally revert or show error. For now, we'll reload to stay consistent.
      loadNotifications();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    // Optimistic update
    final currentState = state;
    if (currentState.status == Status.completed && currentState.data != null) {
      final updatedList = currentState.data!
          .where((notification) => notification.id != notificationId)
          .toList();
      state = ApiResponse.completed(updatedList);
    }

    final response = await _notificationApiService.deleteNotification(
      notificationId,
    );

    if (response.status == Status.error) {
      loadNotifications();
    }
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}
