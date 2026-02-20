import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:smart_text_thief/Core/Services/Api/api_response_model.dart';

import 'api_endpoints.dart';
import 'api_interceptor.dart';

class DioHelper {
  static late Dio dio;
  static bool _initialized = false;

  static Future<void> init() async{
    if (_initialized) {
      return;
    }

    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        receiveDataWhenStatusError: true,
        // connectTimeout: const Duration(seconds: 12),
        // receiveTimeout: const Duration(seconds: 12),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.add(ApiInterceptor());
    _initialized = true;
  }

  static Future<ApiResponseModel<dynamic>> getData({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await dio.get(
      path,   
      queryParameters: queryParameters,
    );
    return ApiResponseModel<dynamic>.fromJson(
      response.data,
      (data) => data,
    );
  }

  static Future<ApiResponseModel<dynamic>> postData({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    log("post data");
    final response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return ApiResponseModel<dynamic>.fromJson(
      response.data,
      (p) => p,
    );
  }

  static Future<Response<dynamic>> putData({
    required String path,
    required dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  static Future<Response<dynamic>> deleteData({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }
}
