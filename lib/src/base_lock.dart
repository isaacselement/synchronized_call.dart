import 'dart:async';

import 'package:synchronized_call/synchronized_call.dart';

abstract class CallLock with CallListener {
  /// return true if currently is locked, that means there is executing block here and not finish
  bool get isLocking;

  FutureOr<T> call<T>(FutureOr<T> Function() fn);

  /// call when the all blocks are done executed, notify to the listeners
  void finish() {
    notifyListeners();
  }

  /// create a new instance
  static create({bool? isSync}) => SerialLock(isSync: isSync);

  /// maintain a maned lock instances
  static final Map<String, CallLock> _namedLocks = {};

  static Map<String, CallLock> get locks => _namedLocks;

  static CallLock get(String name) => (_namedLocks[name] ??= CallLock.create());

  static CallLock set(String name, CallLock lock) => (_namedLocks[name] = lock);

  static CallLock? remove(String name) => _namedLocks.remove(name);

  static void removeLock(CallLock lock) => _namedLocks.removeWhere((k, v) => v == lock);

  /// maintain a named lock by T
  static CallLock got<T extends CallLock>([String? name]) {
    String key = 'Got.${T.toString()}';
    if (name != null) {
      key = '$key.$name';
    }
    CallLock? lock = _namedLocks[key];
    if (lock != null) return lock as T;
    if (T == SyncLock) {
      lock = SyncLock();
    } else if (T == SerialLock) {
      lock = SerialLock();
    } else if (T == InclusiveLock) {
      lock = InclusiveLock();
    }
    if (lock != null) {
      _namedLocks[key] = lock;
    }
    assert(lock != null, 'ERROR: Cannot create a new [${T.toString()}] instance, please register here.');
    return lock ?? get(key);
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
