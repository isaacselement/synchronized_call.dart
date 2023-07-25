import 'dart:async';

import 'package:synchronized_call/src/base_lock.dart';

/**
 * Serial Queue
 **/

/// Inspired by https://pub.dev/packages/synchronized
/// Different from [SerialLock], synchronized package's [Lock] & [SyncLock] here will create ths same number of Completer as calls come in at the same time
/// If you call [Lock.synchronized]/[SyncLock.call] 1000 times, it will create 1000 Completer, then each Completer will be completed one by one
/// So, we recommended to use [SerialLock] instead of [Lock]/[SyncLock] in most cases
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
  bool get isRunning => _completer != null;
}
