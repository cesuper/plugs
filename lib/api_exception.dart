import 'dart:convert';

class ApiException implements Exception {
  ///
  ApiException(this.code, String? message) {
    if (message != null) {
      try {
        var decoded = json.decode(message);
        this.message = decoded['message'];
      } catch (e) {
        this.message = message;
      }
    }
  }

  ApiException.withInner(
      this.code, this.message, this.innerException, this.stackTrace);

  int code = 0;
  String? message;
  Exception? innerException;
  StackTrace? stackTrace;

  @override
  String toString() {
    if (message == null) {
      return 'ApiException';
    }
    if (innerException == null) {
      return 'ApiException $code: $message';
    }
    return 'ApiException $code: $message (Inner exception: $innerException)\n\n$stackTrace';
  }
}
