import 'dart:async';

import 'package:synchronized_call/src/serial_lock.dart';
import 'package:synchronized_call/src/sync_lock.dart';

abstract class Lock {
  /// create new instance
  factory Lock({bool? isSync}) => isSync == true ? SyncLock() : SerialLock();

  /// maintain a maned lock instances
  static final Map<String, Lock> _namedLocks = {};

  static Map<String, Lock> get locks => _namedLocks;

  static Lock get(String name) => (_namedLocks[name] ??= Lock());

  static Lock set(String name, Lock lock) => (_namedLocks[name] = lock);

  static Lock? remove(String name) => _namedLocks.remove(name);

  /// return true if currently is locked, that means there is executing block here and not finish
  bool get isLocking;

  Future<T> call<T>(FutureOr<T> Function() fn);
}
