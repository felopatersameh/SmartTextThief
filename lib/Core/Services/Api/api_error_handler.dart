import 'package:dio/dio.dart';

abstract class Failure {
  final String errMessage;

  const Failure(this.errMessage);
}

class ServerFailure extends Failure {
  const ServerFailure(super.errMessage);

  static Failure fromDioError(DioException error) {
    if (error.response?.statusCode == 401) {
      return const UnauthenticatedFailure();
    }

    if (error.response != null) {
      final serverMessage = _extractServerMessage(error.response?.data);
      if (serverMessage.isNotEmpty) {
        return ServerFailure(serverMessage);
      }
      if (error.response?.statusCode != null) {
        return ServerFailure(_handleStatusCode(error.response!.statusCode!));
      }
    }

    return ServerFailure(_handleDioError(error));
  }

  static String _handleStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 405:
        return 'Method not allowed';
      case 408:
        return 'Request timeout';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      case 504:
        return 'Gateway timeout';
      default:
        return 'Unexpected server error ($statusCode)';
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badCertificate:
        return 'Bad certificate';
      case DioExceptionType.badResponse:
        return 'Bad response';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      default:
        return 'Unknown error';
    }
  }

  static String _extractServerMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? data['error']?.toString() ?? '';
    }
    return data?.toString() ?? '';
  }
}

class UnauthenticatedFailure extends Failure {
  const UnauthenticatedFailure() : super('Unauthorized');
}
