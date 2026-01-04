import 'package:dio/dio.dart';
import 'package:tracky_mobile/core/models/api_response.dart';
import 'package:tracky_mobile/core/network/dio_interceptor.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
      ),
    );

    _dio.interceptors.add(DioInterceptor(_dio));
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      if (response.isSuccess) {
        return ApiResponse.completed(response.data);
      }
      return ApiResponse.error(response.data['message']);
    } on DioException {
      rethrow;
    }
  }

  Future<ApiResponse<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      if (response.isSuccess) {
        return ApiResponse.completed(response.data);
      }
      return ApiResponse.error(response.data['message']);
    } on DioException {
      rethrow;
    }
  }

  Future<ApiResponse<T>> put<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      if (response.isSuccess) {
        return ApiResponse.completed(response.data);
      }
      return ApiResponse.error(response.data['message']);
    } on DioException {
      rethrow;
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      if (response.isSuccess) {
        return ApiResponse.completed(response.data);
      }
      return ApiResponse.error(response.data['message']);
    } on DioException {
      rethrow;
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      if (response.isSuccess) {
        return ApiResponse.completed(response.data);
      }
      return ApiResponse.error(response.data['message']);
    } on DioException {
      rethrow;
    }
  }
}
