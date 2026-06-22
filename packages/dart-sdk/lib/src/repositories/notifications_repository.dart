import '../client/api_client.dart';
import '../models/app_notification.dart';

class NotificationsRepository {
  final ApiClient _api;
  final String _basePath;

  NotificationsRepository({
    required ApiClient apiClient,
    String basePath = '/api/notifications',
  })  : _api = apiClient,
        _basePath = basePath;

  Future<List<AppNotification>> list({int page = 1, int pageSize = 20}) async {
    final response = await _api.get(
      _basePath,
      params: {
        'page': page.toString(),
        'page_size': pageSize.toString(),
      },
    );

    List<dynamic> rawList;
    if (response is List) {
      rawList = response;
    } else if (response is Map) {
      rawList = response['data'] ?? response['notifications'] ?? response['results'] ?? [];
    } else {
      rawList = [];
    }

    return rawList
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppNotification> markAsRead(String id) async {
    final response = await _api.patch('$_basePath/$id/read');
    return AppNotification.fromJson(response as Map<String, dynamic>);
  }

  Future<void> markAllAsRead() async {
    await _api.patch('$_basePath/read-all');
  }

  Future<void> delete(String id) async {
    await _api.delete('$_basePath/$id');
  }

  Future<int> getUnreadCount() async {
    final response = await _api.get('$_basePath/unread-count');
    if (response is Map) {
      return (response['count'] as num?)?.toInt() ?? 0;
    }
    return (response as num?)?.toInt() ?? 0;
  }
}
