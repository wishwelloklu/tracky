import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:tracky_mobile/core/services/storage_service.dart';

class DioInterceptor extends Interceptor {
  final Dio dio;

  DioInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.baseUrl = 'http://192.168.0.102:8080';
    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    log(
      '--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}',
    );
    log('Headers: ${options.headers}');
    log('Payload: ${json.encode(options.data)}');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('<-- ${response.statusCode} ${response.requestOptions.uri}');
    log('Response Data: ${json.encode(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized (Refresh Token Logic)
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
          final error = err.copyWith(
            message: 'Session expired. Please login again.',
          );
          return handler.next(error);
        }
      } catch (e) {
        await StorageService.logout();
        final error = err.copyWith(
          message: 'Session expired. Please login again.',
        );
        return handler.next(error);
      }
    }

    // Handle other status codes
    String errorMessage = 'An unexpected error occurred';
    final response = err.response;

    if (response != null) {
      log(" error data: ${response.data}");
      if (response.data is Map<String, dynamic> &&
          response.data['message'] != null) {
        errorMessage = response.data['message'];
      } else if (response.data is String) {
        errorMessage = response.data;
      }

      switch (response.statusCode) {
        case 400:
          errorMessage = errorMessage != 'An unexpected error occurred'
              ? errorMessage
              : 'Bad Request';
          break;
        case 403:
          errorMessage =
              'Access Forbidden: You do not have permission to perform this action.';
          break;
        case 404:
          errorMessage = 'Resource Not Found';
          break;
        case 500:
          errorMessage = 'Internal Server Error. Please try again later.';
          break;
        case 502:
        case 503:
          errorMessage = 'Service Unavailable. Please try again later.';
          break;
      }
    } else {
      // Handle network errors
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'Connection Timeout. Please check your internet connection.';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'No Internet Connection.';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request Cancelled.';
          break;
        default:
          errorMessage = 'Network Error. Please try again.';
      }
    }

    // Return the error with the custom message
    final customError = err.copyWith(
      message: errorMessage,
      response:
          err.response, // Keep the original response for debugging if needed
    );
    handler.next(customError);
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
        return response.data['token'];
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}

extension ResponseExtension on Response {
  bool get isSuccess {
    final is200 = statusCode == HttpStatus.ok;
    final is201 = statusCode == HttpStatus.created;
    return is200 || is201;
  }
}
