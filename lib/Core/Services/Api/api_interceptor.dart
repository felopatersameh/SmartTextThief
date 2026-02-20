import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../LocalStorage/local_storage_keys.dart';
import '../../LocalStorage/local_storage_service.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await LocalStorageService.getValue(LocalStorageKeys.token);
    if (token != null && token.toString().isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (kDebugMode) {
      debugPrint('REQUEST ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
          'RESPONSE ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      debugPrint('API ERROR ${err.response?.statusCode} ${err.message}');
    }

    if (err.response?.statusCode == 404) {
      await LocalStorageService.removeValue(LocalStorageKeys.token);
      await LocalStorageService.removeValue(LocalStorageKeys.isLoggedIn);
    }

    handler.next(err);
  }
}
