import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracky_mobile/core/network/dio_client.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});
