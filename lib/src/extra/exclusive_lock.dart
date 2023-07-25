import 'dart:async';

import 'package:synchronized_call/src/base_lock.dart';

/**
 * Head Queue
 **/

/// Just execute the first bloc function in queue, when first bloc is running, others will wait for its result
class ExclusiveLock extends CallLock {
  FutureOr<dynamic>? current;

  int _waiting = 0;

  /// Extra feature for caller if needed
  void Function(dynamic value)? onDoneFirst;

  @override
  FutureOr<T> call<T>(FutureOr<T> Function() fn) async {
    _waiting++;

    /// Scenario: just execute the first bloc, others incoming bloc will wait for it
    current ??= fn();
    var result = await current;
    if (current != null) {
      /// Just set null when first bloc once done
      current = null;

      /// Call the first done callback if any
      onDoneFirst?.call(result);
    }

    if (--_waiting == 0) Future.microtask(() => finish());
    return result;
  }

  @override
  bool get isRunning => _waiting != 0;
}
