import 'dart:async';

import 'package:synchronized_call/src/serial_lock.dart';

abstract class CallLock with CallListener {
  /// create a new instance
  static create({bool? isSync}) => SerialLock(isSync: isSync);

  /// maintain a maned lock instances
  static final Map<String, CallLock> _namedLocks = {};

  static Map<String, CallLock> get locks => _namedLocks;

  static CallLock get(String name) => (_namedLocks[name] ??= CallLock.create());

  static CallLock set(String name, CallLock lock) => (_namedLocks[name] = lock);

  static CallLock? remove(String name) => _namedLocks.remove(name);

  /// return true if currently is locked, that means there is executing block here and not finish
  bool get isLocking;

  FutureOr<T> call<T>(FutureOr<T> Function() fn);

  /// call when the all blocks are done executed, notify to the listeners
  void finish() {
    notifyListeners();
  }
}

/// Listener for monitoring the time when the async functions were executed done
mixin CallListener {
  List<VoidCallback>? _listeners = <VoidCallback>[];

  List get listeners => _listeners!;

  bool get hasListeners => listeners.isNotEmpty;

  void addListener(VoidCallback listener) => listeners.add(listener);

  void removeListener(VoidCallback listener) => listeners.remove(listener);

  void dispose() {
    assert(_listeners != null, 'Listeners already disposed❗️❗️❗️');
    _listeners?.clear();
    _listeners = null;
  }

  void notifyListeners() {
    for (VoidCallback listener in listeners) {
      listener();
    }
  }
}

typedef VoidCallback = void Function();
