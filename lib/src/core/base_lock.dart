import 'dart:async';

typedef VoidFunction = void Function();

/// Listener for monitoring [time and time again] when all the async functions were executed done
mixin CallListener {
  List<VoidFunction>? _listeners = <VoidFunction>[];

  List get listeners => _listeners!;

  bool get hasListeners => listeners.isNotEmpty;

  void addListener(VoidFunction listener) => listeners.add(listener);

  void removeListener(VoidFunction listener) => listeners.remove(listener);

  void dispose() {
    assert(_listeners != null, 'Listeners already disposed❗️❗️❗️');
    _listeners?.clear();
    _listeners = null;
  }

  void notifyListeners() {
    for (VoidFunction listener in listeners) {
      listener();
    }
  }
}

abstract class BaseLock with CallListener {
  /// return true if currently having a bloc running, that means there is executing block or queue is not finished
  bool get isRunning;

  /// call when the all blocks are done executed, notify to the listeners
  void finish() => notifyListeners();

  /// Api for adding async function to the queue
  FutureOr<T> call<T>(FutureOr<T> Function() fn);
}
