import 'dart:async';

import 'package:synchronized_call/synchronized_call.dart';

void main() {
  Future write(int index) async {
    await Future.delayed(Duration(microseconds: 1));
    print('$index');
  }

  Future writeBatch(List<int> indexes) async {
    for (var i in indexes) {
      await write(i);
    }
  }

  void doWrite() async {
    await writeBatch([1, 2, 3, 4, 5]);
    print(' ');
  }

  () async {
    ///
    print('>>>>>>>>> not in sequence');
    for (int i = 0; i < 3; i++) {
      doWrite();
    }

    await Future.delayed(Duration(seconds: 1));

    ///
    print('>>>>>>>>> in sequence');
    Lock lock = Lock();
    for (int i = 0; i < 3; i++) {
      lock.call(doWrite);
    }

    await Future.delayed(Duration(seconds: 1));

    ///
    print('>>>>>>>>> sequence with name ~~~');
    for (int i = 0; i < 5; i++) {
      Lock.get('__test__').call(doWrite);
    }

    await Future.delayed(Duration(seconds: 1));

    ///
    print('>>>>>>>>> sequence with sync ~~~');
    Lock.set('__sync_lock__', Lock(isSync: true));
    for (int i = 0; i < 5; i++) {
      Lock.get('__sync_lock__').call(doWrite);
    }
  }();
}
