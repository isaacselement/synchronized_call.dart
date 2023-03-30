# synchronized_call

Synchronized mechanism for async function calls, to prevent concurrent access to the asynchronous code.


## Feature

* Pure `Dart` language. No dependencies

Inspired by [`synchronized`](https://pub.dev/packages/synchronized) package, but it erase weakness that with so many `Completer` create at one time, and support to observer all the bloc is finished.

## Example

Consider the following dummy code

```dart
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
```

Doing

```dart
doWrite();
doWrite();
doWrite();

/// will print: '111222333444555'
/// but we expect: '123451234512345'
```

So using the `Lock` in `synchronized_call` package:

```dart
Lock lock = Lock();

lock.call(doWrite);
lock.call(doWrite);
lock.call(doWrite);

/// now the output will be: '123451234512345'
```


## Features and bugs

Please feel free to:
request new features and bugs at the [issue tracker][tracker]



[tracker]: https://github.com/isaacselement/synchronized_call.dart/issues