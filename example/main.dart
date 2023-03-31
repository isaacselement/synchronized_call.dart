import 'dart:async';
import 'dart:io';

import 'package:synchronized_call/synchronized_call.dart';

void main() {
  Future writeBatch(List<int> indexes) async {
    for (var i in indexes) {
      await Future.delayed(Duration(milliseconds: 100));
      stdout.write('$i');
    }
  }

  Future<int> doWrite() async {
    await writeBatch([1, 2, 3, 4, 5]);
    print('');
    return 0;
  }

  () async {
    int _count = 5;

    ///
    print('>>>>>>>>> Not in sequence');
    for (int i = 0; i < _count; i++) {
      doWrite();
    }
    await Future.delayed(Duration(seconds: 3));

    ///
    print('>>>>>>>>> Start [SerialLock] async test');
    CallLock lock = CallLock.create();
    for (int i = 0; i < _count; i++) {
      lock.call(doWrite);
    }
    lock.addListener(() {
      print('>>>>>>>>> Done [SerialLock] async test');
    });
    await Future.delayed(Duration(seconds: 3));

    ///
    print('>>>>>>>>> Start [SerialLock] sync test');
    CallLock syncLock = CallLock.create(isSync: true);
    for (int i = 0; i < _count; i++) {
      syncLock.call(doWrite);
    }
    syncLock.addListener(() {
      print('>>>>>>>>> Done [SerialLock] sync test');
    });
    await Future.delayed(Duration(seconds: 3));

    ///
    print('>>>>>>>>> Start [SerialLock] test with name ~~~');
    for (int i = 0; i < _count; i++) {
      CallLock.get('__async_test__').call(doWrite);
    }
    CallLock.get('__async_test__').addListener(() {
      print('>>>>>>>>> Done [SerialLock] test with name ~~~');
    });
    await Future.delayed(Duration(seconds: 3));

    ///
    print('>>>>>>>>> Start [SyncLock] async test');
    CallLock.set('__async_lock__', SyncLock());
    for (int i = 0; i < _count; i++) {
      CallLock.get('__async_lock__').call(doWrite);
    }
    CallLock.get('__async_lock__').addListener(() {
      print('>>>>>>>>> Done [SyncLock] async test');
    });
    await Future.delayed(Duration(seconds: 3));

    ///
    print('>>>>>>>>> Start [SyncLock] sync test');
    CallLock.set('__sync_lock__', SyncLock(isSync: true));
    for (int i = 0; i < _count; i++) {
      CallLock.get('__sync_lock__').call(doWrite);
    }
    CallLock.get('__sync_lock__').addListener(() {
      print('>>>>>>>>> Done [SyncLock] sync test');
    });
    await Future.delayed(Duration(seconds: 3));
  }();
}
