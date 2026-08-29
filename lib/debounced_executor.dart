import "dart:async";

class DebouncedExecutor {
  Timer? _timer;
  final Duration delay;

  DebouncedExecutor({this.delay = const Duration(milliseconds: 500)});

  void request( Future<void> fn() ) {
    _timer?.cancel();
    _timer = Timer(delay, () async {
      await fn();
    });
  }

  void dispose() => _timer?.cancel();
}
