import 'dart:async';
import 'dart:io';

import 'package:synchronized_call/synchronized_call.dart';

void main() {
  testId();
  testGot();
  // testSyncCall();
}

void testSyncCall() {
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
      print('>>>>>>>>> Done [SerialLock] async test\n');
    });
    await Future.delayed(Duration(seconds: 3));

    ///
    print('>>>>>>>>> Start [SerialLock] sync test, using Completer.sync()');
    CallLock syncLock = CallLock.create(isSync: true);
    for (int i = 0; i < _count; i++) {
      syncLock.call(doWrite);
    }
    syncLock.addListener(() {
      print('>>>>>>>>> Done [SerialLock] sync test\n');
    });
    await Future.delayed(Duration(seconds: 3));

    ///
    print('>>>>>>>>> Start [SerialLock] test with name ~~~');
    for (int i = 0; i < _count; i++) {
      CallLock.get('__async_test__').call(doWrite);
    }
    CallLock.get('__async_test__').addListener(() {
      print('>>>>>>>>> Done [SerialLock] test with name ~~~\n');
    });
    await Future.delayed(Duration(seconds: 3));

    ///
    print('>>>>>>>>> Start [SyncLock] async test');
    CallLock.set('__async_lock__', SyncLock());
    for (int i = 0; i < _count; i++) {
      CallLock.get('__async_lock__').call(doWrite);
    }
    CallLock.get('__async_lock__').addListener(() {
      print('>>>>>>>>> Done [SyncLock] async test\n');
    });
    await Future.delayed(Duration(seconds: 3));

    ///
    print('>>>>>>>>> Start [SyncLock] sync test, using Completer.sync()');
    CallLock.set('__sync_lock__', SyncLock(isSync: true));
    for (int i = 0; i < _count; i++) {
      CallLock.get('__sync_lock__').call(doWrite);
    }
    CallLock.get('__sync_lock__').addListener(() {
      print('>>>>>>>>> Done [SyncLock] sync test\n');
    });
    await Future.delayed(Duration(seconds: 3));
  }();
}

void testGot() {
  CallLock callLock = CallLock.got();
  print('GOT: $callLock');
}

void testId() {
  String identifier = '11EE-1122-11EE-1122';
  CallLock callLock = CallLock.id(identifier);
  callLock.call(() async {
    await Future.delayed(Duration(milliseconds: 500));
    print('------------ In 500s has me? ${CallLock.has('ID.$identifier')} ------------');
  });
  /// Will do the work in queue ~~~
  callLock.call(() async {
    await Future.delayed(Duration(seconds: 2));
    print('------------ done the time-consume 2s work ------------');
  });
  callLock.call(() async {
    await Future.delayed(Duration(seconds: 1));
    print('------------ done the time-consume 1s work ------------');
  });
  callLock.addListener(() {
    print('------------ In done has me? ${CallLock.has('ID.$identifier')} ------------');
  });
}
