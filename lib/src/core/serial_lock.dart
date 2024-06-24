import 'dart:async';

import 'package:synchronized_call/src/core/base_lock.dart';

/// Serial Queue

/// Take advantage of 'a single thread' in dart & await sequence queue
/// When all the waiters are released, they will be asked to wait for `the first released one to be completed`
/// Therefore all the blocs will be executed in sequence

class SerialLock extends BaseLock {
  SerialLock({this.isSync});

  bool? isSync;
  Completer? _completer;

  int _waiting = 0;

  @override
  FutureOr<T> call<T>(FutureOr<T> Function() fn) async {
    _waiting++;
    while (_completer != null) {
      await _completer?.future;
    }
    _completer = isSync == true ? Completer<void>.sync() : Completer<void>();
    try {
      var result = fn();
      return result is Future ? await result : result;
    } finally {
      _waiting--;
      _completer?.complete();
      _completer = null;
      // we can set it to null, cause other waiting the future, not the completer
      if (_waiting == 0) {
        // notify to the listener that task queue is clear/all block is executed
        finish();
      }
    }
  }

  @override
  bool get isRunning => _waiting != 0;
}
