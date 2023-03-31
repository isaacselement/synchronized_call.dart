# synchronized_call


[![pub package](https://img.shields.io/pub/v/synchronized_call.svg)](https://pub.dev/packages/synchronized_call)

## Feature

Synchronized mechanism for `async` function calls

* Prevent concurrent access to the asynchronous code
* Throttle and debounce calls for asynchronous function
* Pure `Dart` language implementation, no other dependencies

Inspired by [`synchronized`](https://pub.dev/packages/synchronized) package, but it eliminates the disadvantage of creating too many `Completer` at once, and supports observers to listen when all blocs were done executed.

##### If you are able to get all Future immediately, recommend to use `Future.forEach`(in turn) or `Future.wait` (order not guaranteed).

## Example

Consider the following dummy code

```dart
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
```

Doing

```dart
doWrite();
doWrite();
doWrite();

/// will print: '111222333444555'
/// but we expect: '12345 12345 12345'
```

So using the `CallLock` in `synchronized_call` package:

```dart
import 'package:synchronized_call/synchronized_call.dart';
CallLock lock = CallLock.create();

lock.call(doWrite);
lock.call(doWrite);
lock.call(doWrite);

/// now the output will be: '12345 12345 12345'
```

Want to receive a callback when all bloc invoked in queue were done:
```dart
lock.addListener(() {
  print('All bloc are done executed.');
});
```

##### Except for `SerialLock` and `SyncLock`, a extra lock called `InclusiveLock` provides functionality that execute only head-to-tail bloc tasks, please feel free to use :)

## Features and bugs

Please feel free to:
request new features and bugs at the [issue tracker][tracker]



[tracker]: https://github.com/isaacselement/synchronized_call.dart/issues