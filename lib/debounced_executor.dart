import "dart:async";

class DebouncedExecutor {
  Timer? _timer;
  final Duration delay;
  final Future<void> Function() _fn;

  DebouncedExecutor(Future<void> Function() fn, {this.delay = const Duration(milliseconds: 500)}) : _fn = fn;

  void requestPersist() {
    _timer?.cancel();
    _timer = Timer(delay, () async {
      await _fn();
    });
  }

  void dispose() => _timer?.cancel();
}
