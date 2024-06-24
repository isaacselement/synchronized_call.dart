import 'package:synchronized_call/src/misc/lockers.dart';

Locker locker = Locker();
LockFusion lockFusion = LockFusion();
LockFission lockFission = LockFission();
LockSuperior lockSuperior = LockSuperior();
LockGovernor lockGovernor = LockGovernor();

void main(List<String> arguments) async {
  print('Testing Locker...');
  for (int i = 0; i < 5; i++) {
    startWithLocker(i, true);
  }
  await Future.delayed(Duration(seconds: 6));
  // print('If Locker clear? ${locker.nowDoing}');

  print('Testing LockFusion...');
  for (int i = 0; i < 5; i++) {
    startWithLockFusion(i, true);
  }
  await Future.delayed(Duration(seconds: 6));
  // print('If LockFusion clear? ${lockFusion.nowDoing}');

  print('Testing LockFission...');
  for (int i = 0; i < 5; i++) {
    startWithLockFission(i, true);
  }
  await Future.delayed(Duration(seconds: 6));
  // print('If LockFission clear? ${lockFission.nowDoing}');

  print('Testing LockSuperior...');
  for (int i = 0; i < 5; i++) {
    lockSuperior.lock(() => _longTimeTask(i));
  }
  await Future.delayed(Duration(seconds: 6));
  // print('If LockSuperior clear? ${lockSuperior.nowDoing}');

  print('Testing LockGovernor...');
  for (int i = 0; i < 5; i++) {
    lockGovernor.lock(() => _longTimeTask(i));
  }
  await Future.delayed(Duration(seconds: 6));
  // print('If LockGovernor clear? ${lockGovernor.nowDoing}');
}

void startWithLocker(int i, bool enable) async {
  if (enable) await locker.lock();
  await _longTimeTask(i);
  if (enable) locker.unlock();
}

void startWithLockFusion(int i, bool enable) async {
  if (enable) await lockFusion.lock();
  await _longTimeTask(i);
  if (enable) lockFusion.unlock();
}

void startWithLockFission(int i, bool enable) async {
  if (enable) await lockFission.lock();
  await _longTimeTask(i);
  if (enable) lockFission.unlock();
}

Future<void> _longTimeTask(int i) async {
  print('long task start: $i');
  await Future.delayed(Duration(seconds: 1));
  print('long task done: $i');
}
