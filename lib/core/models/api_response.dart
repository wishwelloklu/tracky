// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ApiResponse<T> {
  Status? status;
  T? data;
  String message = "";
  bool isLoading;

  ApiResponse({
    this.message = "Unknown error occurred",
    this.data,
    this.status,
    this.isLoading = false,
  });
  ApiResponse.completed(this.data)
    : status = Status.completed,
      isLoading = false;
  ApiResponse.error(this.message) : status = Status.error, isLoading = false;
  ApiResponse.init()
    : status = null,
      data = null,
      message = '',
      isLoading = false;

  bool isInitialState() => !(status == Status.completed && data != null);
  bool get isSuccess => status == Status.completed;
  bool get isError => status == Status.error;

  ApiResponse<T> copiedLoading(bool isLoading) => ApiResponse<T>(
    status: Status.loading,
    data: data,
    message: message,
    isLoading: isLoading,
  );

  ApiResponse<T> copiedError(String errorMessage) => ApiResponse<T>(
    status: Status.error,
    data: null,
    message: errorMessage,
    isLoading: false,
  );

  ApiResponse<T> copiedSuccess(T? response) => ApiResponse<T>(
    status: Status.completed,
    data: response,
    message: message,
    isLoading: false,
  );

  Widget when({
    required Widget Function(T data) done,
    required Widget Function(String message) error,
    required Widget Function() loading,
  }) {
    switch (status) {
      case Status.idle:
        {
          return const SizedBox.shrink();
        }
      case Status.loading:
        {
          return loading();
        }
      case Status.completed:
        {
          return done(data as T);
        }
      case Status.error:
        {
          return error(message);
        }
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  bool operator ==(covariant ApiResponse<T> other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        other.data == data &&
        other.message == message &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        data.hashCode ^
        message.hashCode ^
        isLoading.hashCode;
  }

  @override
  String toString() => "Status : $status \n Message : $message \n Data : $data";
}

enum Status { idle, loading, completed, error }
