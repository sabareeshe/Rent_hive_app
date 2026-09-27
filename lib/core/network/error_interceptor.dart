import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An unexpected error occurred';

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      errorMessage = 'Connection timed out. Please try again.';
    } else if (err.type == DioExceptionType.badResponse) {
      if (err.response?.data != null && err.response?.data is Map && err.response?.data['message'] != null) {
        errorMessage = err.response?.data['message'];
      } else {
        switch (err.response?.statusCode) {
          case 400:
            errorMessage = 'Bad Request';
            break;
          case 401:
            errorMessage = 'Unauthorized. Please login again.';
            break;
          case 403:
            errorMessage = 'Forbidden';
            break;
          case 404:
            errorMessage = 'Resource not found';
            break;
          case 500:
            errorMessage = 'Internal server error';
            break;
          default:
            errorMessage = 'Received invalid status code: ${err.response?.statusCode}';
        }
      }
    } else if (err.type == DioExceptionType.connectionError) {
      errorMessage = 'No Internet connection';
    }

    // Wrap the error message in a custom Exception or modify the DioException
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage, // We set the custom message here
    );

    super.onError(customError, handler);
  }
}
