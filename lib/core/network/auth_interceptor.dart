import 'package:dio/dio.dart';
import 'package:tracky_mobile/core/services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      RequestOptions options = err.requestOptions;
      // If the token has been updated by another request, retry directly
      final currentToken = StorageService.getToken();
      if (currentToken != null &&
          options.headers['Authorization'] != 'Bearer $currentToken') {
        options.headers['Authorization'] = 'Bearer $currentToken';
        try {
          final response = await dio.fetch(options);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }

      try {
        final newToken = await _refreshToken();
        if (newToken != null) {
          await StorageService.saveToken(newToken);
          options.headers['Authorization'] = 'Bearer $newToken';
          final response = await dio.fetch(options);
          return handler.resolve(response);
        } else {
          await StorageService.logout();
          return handler.next(err);
        }
      } catch (e) {
        await StorageService.logout();
        return handler.next(err);
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    try {
      // Create a new Dio instance to avoid interceptor loops
      final refreshDio = Dio(BaseOptions(baseUrl: 'https://192.168.0.102'));
      // Assuming refresh endpoint is /refresh-token or similar.
      // Using generic structure as specific endpoint wasn't provided.
      // You might need to pass the refresh token here if you have one.
      // For now, assuming standard access token refresh flow.
      final response = await refreshDio.post('/auth/refresh-token');
      if (response.statusCode == 200) {
        return response
            .data['token']; // Adjust based on actual response structure
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
