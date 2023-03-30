import 'dart:async';

import 'package:synchronized_call/src/base_lock.dart';

/// Take advantage of 'a single thread' in dart & await sequence queue.
class SerialLock extends CallLock {
  Completer? _completer;

  int _locking = 0;

  @override
  Future<T> call<T>(FutureOr<T> Function() fn) async {
    _locking++;
    while (_completer != null) {
      await _completer?.future;
    }
    _completer = Completer();
    try {
      var result = fn();
      return result is Future ? await result : result;
    } finally {
      _locking--;
      _completer?.complete();
      _completer = null;
      // we can set it to null, cause other waiting the future, not the completer
      if (_locking == 0) {
        // notify to the listener that task queue is clear/all block is executed
        finish();
      }
    }
  }

  @override
  bool get isLocking => _locking == 0;
}
