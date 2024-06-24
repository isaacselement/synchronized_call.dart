import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:test/test.dart';

import 'package:synchronized_call/synchronized_call.dart';

class BlocLongTask {
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

void main(List<String> arguments) async {
  /// InclusiveLock Test
  print('>>>>>>>>> Start [InclusiveLock] Test');
  InclusiveLock inclusiveLock = InclusiveLock();
  BlocLongTask inclusiveTask = BlocLongTask();
  for (int i = 0; i < 5; i++) {
    FutureOr futureOr = inclusiveLock.call(inclusiveTask.doWrite);
    print('Caller request to add a new task to execute $i');
    if (futureOr is Future) {
      futureOr.then((value) {
        DateTime now = DateTime.now();
        print('$now ----->>>>>>>>> Got the return value: $value, ${value == inclusiveTask.finalResultValue}');
        expect(value == inclusiveTask.finalResultValue, isTrue);
      });
    }
  }
  inclusiveLock.addListener(() {
    print('>>>>>>>>> Done [InclusiveLock] test');
  });
  await Future.delayed(Duration(seconds: 2));
  expect(true, isTrue);

  /// ExclusiveLock Test
  print('>>>>>>>>> Start [ExclusiveLock] Test');
  ExclusiveLock exclusiveLock = ExclusiveLock();
  BlocLongTask exclusiveTask = BlocLongTask();
  for (int i = 0; i < 10; i++) {
    FutureOr futureOr = exclusiveLock.call(exclusiveTask.doWrite);
    print('Caller request to add a new task to execute $i');
    if (futureOr is Future) {
      futureOr.then((value) {
        DateTime now = DateTime.now();
        print('$now ----->>>>>>>>> Got the return value: $value, ${value == exclusiveTask.firstResultValue}');
        expect(value == exclusiveTask.firstResultValue, isTrue);
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
}
