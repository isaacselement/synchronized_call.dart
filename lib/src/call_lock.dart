import 'package:synchronized_call/synchronized_call.dart';

/// Manager of lock instances
class CallLock {
  /// private constructor
  CallLock._();

  /// create a new instance
  static BaseLock create({bool? isSync}) => SerialLock(isSync: isSync);

  /// maintain a maned lock instances cache
  static final Map<String, BaseLock> _namedLocks = {};

  static Map<String, BaseLock> get locks => _namedLocks;

  static bool has(String name) => (_namedLocks[name] != null);

  static BaseLock get(String name) => (_namedLocks[name] ??= CallLock.create());

  static BaseLock set(String name, BaseLock lock) => (_namedLocks[name] = lock);

  static BaseLock setIfNull(String name, BaseLock lock) => (_namedLocks[name] ??= lock);

  static BaseLock? remove(String name) => _namedLocks.remove(name);

  static void removeLock(BaseLock lock) => _namedLocks.removeWhere((k, v) => v == lock);

  /// create a new instance by supported T, if T is not supported, return null
  static T? createByType<T extends BaseLock>() {
    BaseLock? lock;
    if (T == BaseLock) {
      // when T is not specified, use SyncLock as default
      lock = SyncLock();
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
  static BaseLock got<T extends BaseLock>([String? name]) {
    // when T is not specified, key will be 'Got.BaseLock'
    String key = 'GOT.${T.toString()}';
    if (name != null) key = '$key.$name';
    // return if already exist in cache
    BaseLock? lock = _namedLocks[key];
    if (lock != null) return lock;

    // create a new instance by T
    lock = createByType<T>();
    // if lock is null, use default instance create by get
    lock ??= get(key);
    _namedLocks[key] = lock;
    return lock;
  }

  /// return a lock instance by identifier, the lock will be remove from cache when all blocks are done executed
  static BaseLock id<T extends BaseLock>(String identifier) {
    String key = 'ID.$identifier';
    BaseLock? lock = _namedLocks[key];
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
