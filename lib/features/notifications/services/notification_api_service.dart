import 'package:tracky_mobile/core/models/api_response.dart';
import 'package:tracky_mobile/core/network/dio_client.dart';
import 'package:tracky_mobile/features/notifications/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracky_mobile/core/network/dio_provider.dart';

class NotificationApiService {
  final DioClient _dioClient;

  NotificationApiService(this._dioClient);

  Future<ApiResponse<List<NotificationModel>>> fetchNotifications() async {
    try {
      final response = await _dioClient.get('/api/v1/notifications/');

      if (response.status == Status.completed) {
        final List<dynamic> data = response.data['data'];
        final notifications = data
            .map((json) => NotificationModel.fromJson(json))
            .toList();
        return ApiResponse.completed(notifications);
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<void>> markAsRead(String notificationId) async {
    try {
      final response = await _dioClient.patch(
        '/api/v1/notifications/mark-as-read',
        data: {'notificationId': notificationId, 'read': true},
      );

      if (response.status == Status.completed) {
        return ApiResponse.completed(null);
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<void>> deleteNotification(String notificationId) async {
    try {
      final response = await _dioClient.delete(
        '/api/v1/notifications/delete/$notificationId',
      );

      if (response.status == Status.completed) {
        return ApiResponse.completed(null);
      }
      return ApiResponse.error(response.message);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}

final notificationApiServiceProvider = Provider<NotificationApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationApiService(dioClient);
});
