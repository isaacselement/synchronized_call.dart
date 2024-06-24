import 'package:synchronized_call/synchronized_call.dart';

void main(List<String> arguments) async {
  BaseLock lock = CallLock.got();
  print('When T is not specified, the instance of `.got()` is: $lock');

  /// Test the CallLock.id will remove the lock or not after the call
  String identifier = '11EE-1122-11EE-1122';
  BaseLock callLock = CallLock.id(identifier);
  callLock.call(() async {
    await Future.delayed(Duration(milliseconds: 500));
    print('------------ In 500s has me? ${CallLock.has('ID.$identifier')} ------------');
  });

  /// Will do the work in order
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
