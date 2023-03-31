import 'dart:async';

import 'package:synchronized_call/src/base_lock.dart';

/// Just execute the first and the last bloc function in queue
class InclusiveLock extends CallLock {
  List<FutureOr<dynamic> Function()> queue = [];

  FutureOr<dynamic>? current;

  int _locking = 0;

  @override
  FutureOr<T> call<T>(FutureOr<T> Function() fn) async {
    _locking++;

    /// clear before add, only keep the newest bloc task in queue, make it seems hollow the queue
    /// so we can achieve the goal: just execute the first and the last bloc that the caller requested
    queue.clear();
    queue.add(fn);
    var result = execute();
    return result is Future ? await result : result;
  }

  FutureOr<dynamic> execute({dynamic result}) async {
    /// use `while` cause the 'current' may changed, when caller constantly add new bloc using 'call' method
    while (current != null) {
      result = await current;
    }
    if (queue.isNotEmpty) {
      /// take out the last bloc in queue, call it may take a long time
      result = queue.removeLast()();
      if (result is Future) {
        current = result;
        result = await result;
        current = null;
      }

      /// check if any updated in queue again
      return await execute(result: result);
    }
    if (--_locking == 0) Future.microtask(() => finish());
    return result;
  }

  @override
  bool get isLocking => queue.isNotEmpty && current == null;
}
