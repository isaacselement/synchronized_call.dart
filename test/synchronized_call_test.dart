import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:test/test.dart';

import 'package:synchronized_call/synchronized_call.dart';

void main() {
  group('A group of [InclusiveLock] tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('InclusiveLock Test', () async {
      print('>>>>>>>>> Start [InclusiveLock] test');
      InclusiveLock inclusiveLock = InclusiveLock();
      int _count = 5;
      BlocTask task = BlocTask();
      for (int i = 0; i < _count; i++) {
        FutureOr futureOr = inclusiveLock.call(task.doWrite);
        print('Caller request to add a new task to execute $i');
        if (futureOr is Future) {
          futureOr.then((value) {
            DateTime now = DateTime.now();
            print('$now ----->>>>>>>>> Got the return value: $value, ${value == task.finalResultValue}');
            expect(value == task.finalResultValue, isTrue);
          });
        }
      }
      inclusiveLock.addListener(() {
        print('>>>>>>>>> Done [InclusiveLock] test');
      });
      await Future.delayed(Duration(seconds: 2));
      expect(true, isTrue);
    });

    test('ExclusiveLock Test', () async {
      print('>>>>>>>>> Start [ExclusiveLock] test');
      ExclusiveLock exclusiveLock = ExclusiveLock();
      int _count = 10;
      BlocTask task = BlocTask();
      for (int i = 0; i < _count; i++) {
        FutureOr futureOr = exclusiveLock.call(task.doWrite);
        print('Caller request to add a new task to execute $i');
        if (futureOr is Future) {
          futureOr.then((value) {
            DateTime now = DateTime.now();
            print('$now ----->>>>>>>>> Got the return value: $value, ${value == task.firstResultValue}');
            expect(value == task.firstResultValue, isTrue);
          });
        }
      }
      exclusiveLock.addListener(() {
        print('>>>>>>>>> Done [ExclusiveLock] test');
      });
      exclusiveLock.onDoneFirst = (v) {
        print('>>>>>>>>> I got the value on earlier then all of you: $v');
      };
      await Future.delayed(Duration(seconds: 2));
      expect(true, isTrue);
    });
  });
}

class BlocTask {
  int firstResultValue = 0;
  int finalResultValue = 0;

  Future<int> doWrite() async {
    await writeRaw([1, 2, 3, 4, 5]);
    stdout.write('\nWrite done. Generating the return value...\n');
    int returnValue = Random().nextInt(10) + Random().nextInt(10) + 1;
    print('Return value is: $returnValue');

    /// setup values
    if (firstResultValue == 0) {
      firstResultValue = returnValue;
    }
    finalResultValue = returnValue;
    return returnValue;
  }

  Future writeRaw(List<int> indexes) async {
    for (var i in indexes) {
      await Future.delayed(Duration(milliseconds: 100));
      stdout.write('$i');
    }
  }
}
