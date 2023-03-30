import 'dart:async';

import 'package:synchronized_call/synchronized_call.dart';

void main() {
  Future writeBatch(List<int> indexes) async {
    for (var i in indexes) {
      await Future.delayed(Duration(microseconds: 1));
      print('$i');
    }
  }

  void doWrite() async {
    await writeBatch([1, 2, 3, 4, 5]);
    print(' ');
  }

  () async {
    int _count = 5;

    ///
    print('>>>>>>>>> Not in sequence');
    for (int i = 0; i < _count; i++) {
      doWrite();
    }
    await Future.delayed(Duration(seconds: 1));

    ///
    print('>>>>>>>>> Start test async');
    CallLock lock = CallLock.create();
    for (int i = 0; i < _count; i++) {
      lock.call(doWrite);
    }
    lock.addListener(() {
      print('------------->>>>>>> DONE ASYNC');
    });
    await Future.delayed(Duration(seconds: 1));

    ///
    print('>>>>>>>>> Start test sync');
    CallLock syncLock = CallLock.create(isSync: true);
    for (int i = 0; i < _count; i++) {
      syncLock.call(doWrite);
    }
    syncLock.addListener(() {
      print('------------->>>>>>> DONE SYNC');
    });
    await Future.delayed(Duration(seconds: 1));

    ///
    print('>>>>>>>>> Start Test with name async ~~~');
    for (int i = 0; i < _count; i++) {
      CallLock.get('__async_test__').call(doWrite);
    }
    await Future.delayed(Duration(seconds: 1));

    ///
    print('>>>>>>>>> Start Test with name sync ~~~');
    CallLock.set('__sync_lock__', CallLock.create(isSync: true));
    for (int i = 0; i < _count; i++) {
      CallLock.get('__sync_lock__').call(doWrite);
    }
    await Future.delayed(Duration(seconds: 1));
  }();
}
