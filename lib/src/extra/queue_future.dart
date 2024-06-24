import 'dart:async';

import 'package:synchronized_call/synchronized_call.dart';

class QueueFuture extends BaseLock {
  final List<Future> _queue = [];

  /// Add future to the queue. Or use `call` method to add future function.
  void enqueue(Future future) {
    _queue.add(future);
  }

  /// Wait for all futures in the queue to complete then notify listeners. U can add listener or wait for final future
  Future wait() {
    Future finalFuture = Future.wait(_queue);
    finalFuture.then((value) {
      reset();
      notifyListeners();
    });
    return finalFuture;
  }

  /// Clear the queue for re-use
  void reset() {
    _queue.clear();
  }

  @override
  FutureOr<T> call<T>(FutureOr<T> Function() fn) {
    Future<T> future = () async {
      return await fn();
    }();
    _queue.add(future);
    return future;
  }

  @override
  bool get isRunning => _queue.isNotEmpty;
}
