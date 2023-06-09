import 'dart:async';

import 'package:synchronized_call/src/base_lock.dart';

/// Inspired by https://pub.dev/packages/synchronized
/// Different from [SerialLock], the package's Lock & [SyncLock] will create ths same number of Completer as calls come in at the same time
class SyncLock extends CallLock {
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
  bool get isLocking => _completer != null;
}
