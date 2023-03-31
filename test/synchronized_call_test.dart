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

    test('First Test', () async {
      Future writeBatch(List<int> indexes) async {
        for (var i in indexes) {
          await Future.delayed(Duration(milliseconds: 100));
          stdout.write('$i');
        }
      }

      Future<int> doWrite() async {
        await writeBatch([1, 2, 3, 4, 5]);
        print('');
        int returnValue = Random().nextInt(10) + 1;
        print('return value: $returnValue');
        return returnValue;
      }

      int _count = 5;

      ///
      print('>>>>>>>>> Start [InclusiveLock] test');
      InclusiveLock inclusiveLock = InclusiveLock();
      for (int i = 0; i < _count; i++) {
        FutureOr futureOr = inclusiveLock.call(doWrite);
        print('Caller request to add a new task to execute $i');
        if (futureOr is Future) {
          futureOr.then((value) {
            DateTime now = DateTime.now();
            print('$now ----->>>>>>>>> Finally the return value: $value');
          });
        }
      }
      inclusiveLock.addListener(() {
        print('>>>>>>>>> Done [InclusiveLock] test');
      });
      await Future.delayed(Duration(seconds: 3));

      expect(true, isTrue);
    });
  });
}
