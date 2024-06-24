import 'dart:async';

/// Usage: Put async code block between `await lock()` and `unlock()` methods
class Locker {
  Completer? _completer;

  Future<void> lock() async {
    while (_completer != null) {
      await _completer!.future;
    }
    _completer = Completer();
  }

  void unlock() {
    Completer? completer = _completer;
    _completer = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }
}

class LockFusion {
  final List<Completer> _queue = [];

  Future<void> lock() async {
    Completer? previous = _queue.isNotEmpty ? _queue.last : null;
    _queue.add(Completer());
    if (previous != null) {
      await previous.future;
    }
  }

  void unlock() {
    if (_queue.isNotEmpty) {
      Completer completer = _queue.removeAt(0);
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }
}

class _LockElement {
  final Completer completer = Completer();

  _LockElement? next;

  _LockElement get last {
    // return last (if not null) or this
    _LockElement n = this;
    while (n.next != null) {
      n = n.next!;
    }
    return n;
  }

  set last(_LockElement e) {
    // set next for last (if not null) or this
    _LockElement n = this;
    while (n.next != null) {
      n = n.next!;
    }
    n.next = e;
  }
}

class LockFission {
  _LockElement? _doing;

  Future<void> lock() async {
    if (_doing == null) {
      _doing = _LockElement();
      return;
    }
    Completer? completer = _doing?.last.completer;
    _doing?.last = _LockElement();
    if (completer != null) {
      await completer.future;
    }
  }

  void unlock() {
    Completer? completer = _doing?.completer;
    _doing = _doing?.next;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }
}

/// Usage: Pass the async function as parameter to `lock(function)` method
class LockSuperior {
  Completer? _completer;

  Future lock(Future Function() fn) async {
    Completer? previous = _completer;
    Completer completer = Completer();
    _completer = completer;

    if (previous != null) {
      await previous.future;
    }
    await fn();
    completer.complete();

    /// clear
    if (identical(_completer, completer)) {
      _completer = null;
    }
  }
}

class LockGovernor {
  Future? _future;

  Future lock(Future Function() fn) async {
    Future? previous = _future;
    Future current;
    if (previous != null) {
      current = previous.then((v) async {
        await fn();
      });
    } else {
      current = fn();
    }
    _future = current;

    /// clear
    current.then((value) {
      if (identical(_future, current)) {
        _future = null;
      }
    });
    return current;

    /// or use `await` then clear
    // await current;
    // if (identical(_future, current)) {
    //   _future = null;
    // }
  }
}
