import 'dart:async';

import 'package:synchronized_call/src/core/base_lock.dart';

/// Serial Queue

/// Inspired by:
/// https://pub.dev/packages/synchronized
/// https://github.com/tekartik/synchronized.dart/blob/master/synchronized/lib/src/basic_lock.dart
/// It will create ths same number of Completer as call invocations, then each Completer will be completed one by one

class SyncLock extends BaseLock {
  SyncLock({this.isSync});

  bool? isSync;
  Completer? _completer;

  @override
  FutureOr<T> call<T>(FutureOr<T> Function() fn) async {
    Completer? _previous = _completer;
    Completer completer = isSync == true ? Completer.sync() : Completer();
    _completer = completer;

    // Waiting for the previous running block
    if (_previous != null) {
      await _previous.future;
    }
    try {
      var result = fn();
      return result is Future ? await result : result;
    } finally {
      completer.complete();
      if (identical(_completer, completer)) {
        _completer = null;
        // notify to the listener that task queue is clear/all block is executed
        finish();
      }
    }
  }

  @override
  bool get isRunning => _completer != null;
}
