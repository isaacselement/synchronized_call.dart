# synchronized_call


[![pub package](https://img.shields.io/pub/v/synchronized_call.svg)](https://pub.dev/packages/synchronized_call)

## Feature

Synchronized mechanism for `async` function calls. Inspired by [`synchronized`](https://pub.dev/packages/synchronized) package.

* Prevent concurrent access to the asynchronous code
* Throttle and debounce calls for asynchronous function
* Supports add listener to observe whether all async function/bloc are completed


> Differ from `Future.forEach`(in order) or `Future.wait` (order not guaranteed), you can use this/synchronized package at the scenario that without having to get all futures at the same time.

## Example

Consider the following async fuction `doWrite`:

```dart
Future _writeBatch(List<int> indexes) async {
  for (var i in indexes) {
    await Future.delayed(Duration(microseconds: 1));
    print('$i');
  }
}

void doWrite() async {
  await _writeBatch([1, 2, 3, 4, 5]);
  print(' ');
}
```

Calling `doWrite` 3 times:

```dart
doWrite();
doWrite();
doWrite();

/// will print: '111222333444555'
/// but we expect: '12345 12345 12345'
```

Then using the `CallLock` in `synchronized_call` package:

```dart
import 'package:synchronized_call/synchronized_call.dart';

BaseLock lock = CallLock.create();

lock.call(doWrite);
lock.call(doWrite);
lock.call(doWrite);

/// now the output will be you expected: '12345 12345 12345'
```

Want to receive a callback when all bloc were done executed:
```dart
lock.addListener(() {
  print('All bloc are done executed.');
});
```

## Another way to Use
Put async codes/bloc between `await lock()` and `unlock()` methods


    Locker lock = Locker();

    void do() async {
        await lock.lock();
    
        /// ...
        /// other async or sync codes here ...
        /// ...
        await doWrite();
        
        lock.unlock();
    }
    
    do();
    do();
    do();

    /// the output will be you expected: '12345 12345 12345'




## Features and bugs

Please feel free to:
request new features and bugs at the [issue tracker][tracker]



[tracker]: https://github.com/isaacselement/synchronized_call.dart/issues