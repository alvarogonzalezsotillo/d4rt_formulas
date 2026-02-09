/// Centralized error handler that gets notified of every caught exception
class ErrorHandler {
  /// Singleton instance of ErrorHandler
  static final ErrorHandler _instance = ErrorHandler._internal();
  
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Callback function to handle errors - can be overridden for custom behavior
  void Function(Object error, [StackTrace? stackTrace])? onError;

  /// Notifies the error handler of an exception
  void notify(Object error, [StackTrace? stackTrace]) {
    // Print the exception to stdout as requested
    print('ErrorHandler caught exception:');
    print(error);

    if (stackTrace != null) {
      print('Stack trace:');
      print(stackTrace);
    }

    // Call the custom error handler if provided
    onError?.call(error, stackTrace);
  }

  /// Convenience method to wrap code that might throw exceptions
  T handleError<T>(T Function() operation, {T? defaultValue}) {
    try {
      return operation();
    } catch (error, stackTrace) {
      notify(error, stackTrace);

      if (defaultValue != null) {
        return defaultValue;
      }

      rethrow;
    }
  }
}

/// Global instance of ErrorHandler for easy access
final ErrorHandler errorHandler = ErrorHandler();
