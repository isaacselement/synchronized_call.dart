import 'dart:async';

import 'package:synchronized_call/synchronized_call.dart';

class FutureQueue with CallListener {
  final List<Future> _queue = [];

  void reset() {
    _queue.clear();
  }

  void enqueue(Future future) {
    _queue.add(future);
  }

  Future wait() {
    Future f = Future.wait(_queue);
    f.then((value) => notifyListeners());
    return f;
  }
}