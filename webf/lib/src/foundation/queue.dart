/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
// Original version: https://github.com/rknell/dart_queue
import 'dart:async';

class _QueuedFuture<T> {
  final Completer completer;
  final Future<T> Function() closure;
  Function? onComplete;

  _QueuedFuture(this.closure, this.completer);

  Future<void> execute() async {
    try {
      T result = await closure();
      if (result != null) {
        completer.complete(result);
      } else {
        completer.complete(null);
      }
      await Future.microtask(() {});
    } catch (e) {
      completer.completeError(e);
    } finally {
      if (onComplete != null) onComplete!();
    }
  }
}

/// Queue to execute Futures in order.
/// It awaits each future before executing the next one.
class Queue {
  final List<_QueuedFuture> _nextCycle = [];

  /// The number of items to process at one time
  ///
  /// Can be edited mid processing
  int parallel;
  int _lastProcessId = 0;

  StreamController<int>? _remainingItemsController;

  final Set<int> _activeItems = {};

  Queue({this.parallel = 1});

  /// Adds the future-returning closure to the queue.
  ///
  /// It will be executed after futures returned
  /// by preceding closures have been awaited.
  ///
  /// Will throw an exception if the queue has been cancelled.
  Future<T> add<T>(Future<T> Function() closure) {
    final completer = Completer<T>();
    _nextCycle.add(_QueuedFuture<T>(closure, completer));
    _updateRemainingItems();
    _process();
    return completer.future;
  }

  /// Handles the number of parallel tasks firing at any one time
  ///
  /// It does this by checking how many streams are running by querying active
  /// items, and then if it has less than the number of parallel operations fire off another stream.
  ///
  /// When each item completes it will only fire up one othe process
  ///
  Future<void> _process() async {
    if (_activeItems.length < parallel) {
      _queueUpNext();
    }
  }

  void _updateRemainingItems() {
    _remainingItemsController?.sink.add(_nextCycle.length + _activeItems.length);
  }

  void _queueUpNext() {
    if (_nextCycle.isNotEmpty && _activeItems.length <= parallel) {
      final processId = _lastProcessId;
      _activeItems.add(processId);
      final item = _nextCycle.first;
      _lastProcessId++;
      _nextCycle.remove(item);
      item.onComplete = () async {
        _activeItems.remove(processId);
        _updateRemainingItems();
        _queueUpNext();
      };
      item.execute();
    }
  }

  void dispose() {
    _remainingItemsController?.close();
  }
}
