import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioClientProvider = Provider((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.pickleball-hub.com/v1', // Placeholder
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  // Add interceptors (Auth, Logging, etc.)
  dio.interceptors.add(LogInterceptor(responseBody: true));

  return dio;
});
