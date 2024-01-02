import 'dart:async';

import 'package:synchronized_call/synchronized_call.dart';

abstract class CallLock with CallListener {
  /// return true if currently having a bloc running, that means there is executing block or queue is not finished
  bool get isRunning;

  FutureOr<T> call<T>(FutureOr<T> Function() fn);

  /// call when the all blocks are done executed, notify to the listeners
  void finish() {
    notifyListeners();
  }

  /// create a new instance
  static create({bool? isSync}) => SerialLock(isSync: isSync);

  /// maintain a maned lock instances cache
  static final Map<String, CallLock> _namedLocks = {};

  static Map<String, CallLock> get locks => _namedLocks;

  static bool has(String name) => (_namedLocks[name] != null);

  static CallLock get(String name) => (_namedLocks[name] ??= CallLock.create());

  static CallLock set(String name, CallLock lock) => (_namedLocks[name] = lock);

  static CallLock setIfNull(String name, CallLock lock) => (_namedLocks[name] ??= lock);

  static CallLock? remove(String name) => _namedLocks.remove(name);

  static void removeLock(CallLock lock) => _namedLocks.removeWhere((k, v) => v == lock);

  /// create a new instance by supported T, if T is not supported, return null
  static T? createByType<T extends CallLock>() {
    CallLock? lock;
    if (T == CallLock) {
      // when T is not specified, use SerialLock as default
      lock = SerialLock();
    } else if (T == SyncLock) {
      lock = SyncLock();
    } else if (T == SerialLock) {
      lock = SerialLock();
    } else if (T == InclusiveLock) {
      lock = InclusiveLock();
    } else if (T == ExclusiveLock) {
      lock = ExclusiveLock();
    }
    assert(lock != null, 'ERROR: Cannot create a new [${T.toString()}] instance, please register here.');
    return lock as T?;
  }

  /// return maintain a named lock by T
  static CallLock got<T extends CallLock>([String? name]) {
    // when T is not specified, key will be 'Got.CallLock'
    String key = 'GOT.${T.toString()}';
    if (name != null) key = '$key.$name';
    // return if already exist in cache
    CallLock? lock = _namedLocks[key];
    if (lock != null) return lock;

    // create a new instance by T
    lock = createByType<T>();
    // if lock is null, use default instance create by get
    lock ??= get(key);
    _namedLocks[key] = lock;
    return lock;
  }

  /// return a lock instance by identifier, the lock will be remove from cache when all blocks are done executed
  static CallLock id<T extends CallLock>(String identifier) {
    String key = 'ID.$identifier';
    CallLock? lock = _namedLocks[key];
    if (lock != null) return lock;

    // create a new instance by T
    lock = createByType<T>();
    // if lock is null, use default instance create by get
    lock ??= get(key);
    _namedLocks[key] = lock;

    lock.addListener(() {
      _namedLocks.remove(key);
    });
    return lock;
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
