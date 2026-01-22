import 'package:flutter/material.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? userFriendlyMessage;
  final dynamic originalException;

  ApiException({
    this.statusCode,
    required this.message,
    this.userFriendlyMessage,
    this.originalException,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.userFriendlyMessage ?? error.message;
    } else if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please check your connection and try again.';
    }
    return error.toString();
  }

  static ApiException parseException(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    String message = 'An unexpected error occurred';
    String? userMessage;

    if (error is SocketException) {
      message = 'Network error: ${error.message}';
      userMessage = 'Unable to connect to server. Please check your internet connection.';
    } else if (error is TimeoutException) {
      message = 'Request timeout';
      userMessage = 'Request took too long. Please try again.';
    } else if (error is FormatException) {
      message = 'Invalid response format';
      userMessage = 'Server returned invalid data. Please try again.';
    } else if (error is Exception) {
      message = error.toString();
    }

    return ApiException(
      message: message,
      userFriendlyMessage: userMessage,
      originalException: error,
    );
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showErrorDialog(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void logError(dynamic error, StackTrace? stackTrace) {
    print('ERROR: $error');
    if (stackTrace != null) {
      print('STACK TRACE: $stackTrace');
    }
  }
}
