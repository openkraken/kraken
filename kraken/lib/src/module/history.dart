/*
 * Copyright (C) 2019-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
import 'dart:collection';
import 'dart:convert';
import 'dart:async';

import 'package:kraken/dom.dart';
import 'package:kraken/kraken.dart';
import 'package:kraken/module.dart';

class HistoryItem {
  HistoryItem(this.bundle, this.state, this.needJump);
  final KrakenBundle bundle;
  final dynamic state;
  final bool needJump;
}

class HistoryModule extends BaseModule {
  @override
  String get name => 'History';

  HistoryModule(ModuleManager? moduleManager) : super(moduleManager);

  Queue<HistoryItem> get _previousStack => moduleManager!.controller.previousHistoryStack;
  Queue<HistoryItem> get _nextStack => moduleManager!.controller.nextHistoryStack;

  String get href {
    if (_previousStack.isEmpty) return '';
    return _previousStack.first.bundle.src;
  }

  set bundle(KrakenBundle bundle) {
    HistoryItem history = HistoryItem(bundle, null, true);
    _addItem(history);
  }

  void _addItem(HistoryItem historyItem) {
    if (_previousStack.isNotEmpty && historyItem.bundle.src == _previousStack.first.bundle.src) return;

    _previousStack.addFirst(historyItem);

    // Clear.
    while(_nextStack.isNotEmpty) {
      _nextStack.removeFirst();
    }
  }


  void _back() async {
    if (_previousStack.length > 1) {
      HistoryItem currentItem = _previousStack.first;
      _previousStack.removeFirst();
      _nextStack.addFirst(currentItem);

      await _goTo(_previousStack.first.bundle.src);

      dynamic state = _previousStack.first.state;
      _dispatchPopStateEvent(state);
    }
  }

  void _forward() {
    if (_nextStack.isNotEmpty) {
      HistoryItem currentItem = _nextStack.first;
      _nextStack.removeFirst();
      _previousStack.addFirst(currentItem);

      _goTo(currentItem.bundle.src);
      _dispatchPopStateEvent(currentItem.state);
    }
  }

  void _go(num? num) {
    num ??= 0;
    if (num >= 0) {
      if (_nextStack.length < num) {
        return;
      }

      for (int i = 0; i < num; i ++) {
        HistoryItem currentItem = _nextStack.first;
        _nextStack.removeFirst();
        _previousStack.addFirst(currentItem);
      }
    } else {
      if (_previousStack.length - 1 < num.abs()) {
        return;
      }

      for (int i = 0; i < num.abs(); i ++) {
        HistoryItem currentItem = _previousStack.first;
        _previousStack.removeFirst();
        _nextStack.addFirst(currentItem);
      }
    }

    _goTo(_previousStack.first.bundle.src);
    _dispatchPopStateEvent(_previousStack.first.state);
  }

  Future<void> _goTo(String targetUrl) async {
    NavigationModule navigationModule = moduleManager!.getModule<NavigationModule>('Navigation')!;
    await navigationModule.goTo(targetUrl);
  }

  void _dispatchPopStateEvent(dynamic state) {
    PopStateEventInit init = PopStateEventInit(state);
    PopStateEvent popStateEvent = PopStateEvent(init);
    moduleManager!.controller.view.window.dispatchEvent(popStateEvent);
  }

  void _pushState(List<dynamic> params) {
    KrakenController controller = moduleManager!.controller;
    dynamic state = params[0];
    String? url = null;

    if (params[2] != null) {
      url = params[2];

      String currentUrl = _previousStack.first.bundle.src;
      Uri currentUri = Uri.parse(currentUrl);

      Uri uri = Uri.parse(url!);
      uri = controller.uriParser!.resolve(Uri.parse(controller.href), uri);

      if (uri.host.isNotEmpty && uri.host != currentUri.host) {
        print('Failed to execute \'pushState\' on \'History\': '
            'A history state object with URL $url cannot be created in a document with origin ${uri.host} and URL ${currentUri.host}. "');
        return;
      }

      KrakenBundle bundle = KrakenBundle.fromUrl(uri.toString());
      HistoryItem history = HistoryItem(bundle, state, false);
      _addItem(history);
    }
  }

  void _replaceState(List<dynamic> params) {
    KrakenController controller = moduleManager!.controller;
    dynamic state = params[0];
    String? url = null;

    if (params[2] != null) {
      url = params[2];

      String currentUrl = _previousStack.first.bundle.src;
      Uri currentUri = Uri.parse(currentUrl);

      Uri uri = Uri.parse(url!);
      uri = controller.uriParser!.resolve(Uri.parse(controller.href), uri);

      if (uri.host.isNotEmpty && uri.host != currentUri.host) {
        print('Failed to execute \'pushState\' on \'History\': '
            'A history state object with URL $url cannot be created in a document with origin ${uri.host} and URL ${currentUri.host}. "');
        return;
      }

      KrakenBundle bundle = KrakenBundle.fromUrl(uri.toString());
      HistoryItem history = HistoryItem(bundle, state, false);

      _previousStack.removeFirst();
      _previousStack.addFirst(history);
    }
  }

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch(method) {
      case 'length':
        return (_previousStack.length + _nextStack.length).toString();
      case 'state':
        if (_previousStack.isEmpty) {
          return jsonEncode(null);
        }
        HistoryItem history = _previousStack.first;
        return jsonEncode(history.state);
      case 'back':
        _back();
        break;
      case 'forward':
        _forward();
        break;
      case 'pushState':
        _pushState(params);
        break;
      case 'replaceState':
        _replaceState(params);
        break;
      case 'go':
        _go(params);
        break;
    }
    return EMPTY_STRING;
  }

  @override
  void dispose() {
  }
}
