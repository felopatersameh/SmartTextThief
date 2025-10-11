// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';

// class ApiErrorHandler {
//   static ApiErrorModel handleError(dynamic error) {
//     if (error is DioException) {
//       switch (error.type) {
//         case DioExceptionType.connectionTimeout:
//           return ApiErrorModel(
//               message: "⏳ Connection timeout, please try again.");
//         case DioExceptionType.sendTimeout:
//           return ApiErrorModel(
//               message: "🚀 Request send timeout, please try again.");
//         case DioExceptionType.receiveTimeout:
//           return ApiErrorModel(
//               message: "⏳ Response receive timeout, please try again.");
//         case DioExceptionType.badResponse:
//           return _handleBadResponse(error);
//         case DioExceptionType.cancel:
//           return ApiErrorModel(message: "❌ Request was cancelled.");
//         case DioExceptionType.connectionError:
//           return ApiErrorModel(
//               message: "📶 No internet connection, please check your network.");
//         case DioExceptionType.badCertificate:
//           return ApiErrorModel(
//               message:
//                   "⚠️ SSL Certificate error! The server's certificate is invalid or untrusted.");
//         case DioExceptionType.unknown:
//           return ApiErrorModel(
//               message: "⚠️ Unexpected error occurred, please try again.");
//       }
//     } else if (error is SocketException) {
//       return ApiErrorModel(message: "📶 No internet connection.");
//     } else {
//       return ApiErrorModel(message: "⚠️ Unexpected error: ${error.toString()}");
//     }
//   }

//   static ApiErrorModel _handleBadResponse(DioException error) {
//     int? statusCode = error.response?.statusCode;
//     dynamic responseData = error.response?.data;
//     String message = "⚠️ An unexpected error occurred.";
//     Map<String, dynamic>? details;
//     if (responseData is Map<String, dynamic>) {
//       if (responseData.containsKey('message')) {
//         message = responseData['message'];
//       } else if (responseData.containsKey('error')) {
//         message = responseData['error'];
//       }
//       if (responseData.containsKey('errors') &&
//           responseData['errors'] is List) {
//         details = {
//           "errors":
//               List<String>.from(responseData['errors'].map((e) => e.toString()))
//         };
//       }
//     }
//     if (statusCode != null) {
//       switch (statusCode) {
//         case 400:
//           message = message.isNotEmpty
//               ? message
//               : "❌ Bad request, please check your input.";
//           break;
//         case 401:
//           message = message.isNotEmpty
//               ? message
//               : "🔐 Unauthorized, please check your credentials.";
//           break;
//         case 403:
//           message = message.isNotEmpty
//               ? message
//               : "⛔ Forbidden, you don't have permission.";
//           break;
//         case 404:
//           message = message.isNotEmpty ? message : "🔍 Resource not found.";
//           break;
//         case 422:
//           message = message.isNotEmpty
//               ? message
//               : "⚠️ Validation error, please check your inputs.";
//           break;
//         case 500:
//           message = message.isNotEmpty
//               ? message
//               : "🔥 Internal server error, try again later.";
//           break;
//         case 502:
//           message =
//               message.isNotEmpty ? message : "🚧 Bad gateway, try again later.";
//           break;
//         case 503:
//           message = message.isNotEmpty
//               ? message
//               : "🚧 Service unavailable, please try later.";
//           break;
//         default:
//           message = message.isNotEmpty
//               ? message
//               : "⚠️ Unexpected error occurred. Status code: $statusCode";
//       }
//     }
//     if (kDebugMode) {
//       debugPrint("❌ API Error: $message");
//       if (details != null) debugPrint("🔍 Details: ${details.toString()}");
//     }
//     return ApiErrorModel(message: message, details: details);
//   }
// }

// class ApiErrorModel {
//   final String message;
//   final Map<String, dynamic>? details;
//   ApiErrorModel({required this.message, this.details});
//   @override
//   String toString() {
//     return "ApiErrorModel(message: $message, details: $details)";
//   }
// }
