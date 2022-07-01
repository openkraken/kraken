/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

// Bind the JavaScript side object,
// provide interface such as property setter/getter, call a property as function.
import 'dart:collection';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/foundation.dart';

// We have some integrated built-in behavior starting with string prefix reuse the callNativeMethod implements.
const String AnonymousFunctionCallPreFix = '_anonymous_fn_';
const String AsyncAnonymousFunctionCallPreFix = '_anonymous_async_fn_';
const String GetPropertyMagic = '%g';
const String SetPropertyMagic = '%s';

typedef NativeAsyncAnonymousFunctionCallback = Void Function(
    Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, Int32 contextId, Pointer<Utf8> errmsg);
typedef DartAsyncAnonymousFunctionCallback = void Function(Pointer<Void> callbackContext, Pointer<NativeValue> nativeValue, int contextId, Pointer<Utf8> errmsg);

// This function receive calling from binding side.
void _invokeBindingMethodFromNativeImpl(Pointer<NativeBindingObject> nativeBindingObject, Pointer<NativeValue> returnValue, Pointer<NativeString> nativeMethod, int argc, Pointer<NativeValue> argv) {
  String method = nativeStringToString(nativeMethod);
  List<dynamic> values = List.generate(argc, (i) {
    Pointer<NativeValue> nativeValue = argv.elementAt(i);
    return fromNativeValue(nativeValue);
  });

  if (method.startsWith(AnonymousFunctionCallPreFix)) {
    int id = int.parse(method.substring(AnonymousFunctionCallPreFix.length));
    AnonymousNativeFunction fn = getAnonymousNativeFunctionFromId(id)!;
    try {
      var result = fn(values);
      toNativeValue(returnValue, result);
    } catch (e, stack) {
      print('$e\n$stack');
      toNativeValue(returnValue, null);
    }
    removeAnonymousNativeFunctionFromId(id);
  } else if (method.startsWith(AsyncAnonymousFunctionCallPreFix)) {
    int id = int.parse(method.substring(AsyncAnonymousFunctionCallPreFix.length));
    AsyncAnonymousNativeFunction fn = getAsyncAnonymousNativeFunctionFromId(id)!;
    int contextId = values[0];
    Pointer<Void> callbackContext = (values[1] as Pointer).cast<Void>();
    DartAsyncAnonymousFunctionCallback callback = (values[2] as Pointer).cast<NativeFunction<NativeAsyncAnonymousFunctionCallback>>().asFunction();
    Future<dynamic> p = fn(values.sublist(3));
    p.then((result) {
      Pointer<NativeValue> nativeValue = malloc.allocate(sizeOf<NativeValue>());
      toNativeValue(nativeValue, result);
      callback(callbackContext, nativeValue, contextId, nullptr);
      removeAsyncAnonymousNativeFunctionFromId(id);
    }).catchError((e, stack) {
      String errorMessage = '$e';
      callback(callbackContext, nullptr, contextId, errorMessage.toNativeUtf8());
      removeAsyncAnonymousNativeFunctionFromId(id);
    });

    toNativeValue(returnValue, null);
  } else {
    // @TODO: Should not share the same binding method, and separate by magic.
    BindingObject bindingObject = BindingBridge.getBindingObject(nativeBindingObject);
    var result;
    try {
      if (method == GetPropertyMagic && argc == 1) {
        result = bindingObject.getBindingProperty(values[0]);
      } else if (method == SetPropertyMagic && argc == 2) {
        bindingObject.setBindingProperty(values[0], values[1]);
        result = null;
      } else {
        result = bindingObject.invokeBindingMethod(method, values);
      }
    } catch (e, stack) {
      print('$e\n$stack');
    } finally {
      toNativeValue(returnValue, result);
    }
  }
}

List prepareDispatchEventArguments(Event event) {
  Pointer<Void> rawEvent = event.toRaw().cast<Void>();
  bool isCustomEvent = event is CustomEvent;
  return [event.type, rawEvent, isCustomEvent ? 1 : 0];
}

// Dispatch the event to the binding side.
void _dispatchEventToNative(Event event) {
  Pointer<NativeBindingObject>? pointer = event.currentTarget?.pointer;
  int? contextId = event.target?.contextId;
  if (contextId != null && pointer != null) {
    // Call methods implements at C++ side.
    DartInvokeBindingMethodsFromDart f = pointer.ref.invokeBindingMethodFromDart.asFunction();

    List dispatchEventArguments = prepareDispatchEventArguments(event);
    Pointer<NativeString> method = stringToNativeString('dispatchEvent');
    Pointer<NativeValue> allocatedNativeArguments = makeNativeValueArguments(dispatchEventArguments);

    f(pointer, nullptr, method, dispatchEventArguments.length, allocatedNativeArguments);

    // Free the allocated arguments.
    malloc.free(method);
    malloc.free(allocatedNativeArguments);


  }
}

abstract class BindingBridge {
  static final Pointer<NativeFunction<InvokeBindingsMethodsFromNative>> _invokeBindingMethodFromNative = Pointer.fromFunction(_invokeBindingMethodFromNativeImpl);
  static Pointer<NativeFunction<InvokeBindingsMethodsFromNative>> get nativeInvokeBindingMethod => _invokeBindingMethodFromNative;

  static final SplayTreeMap<int, BindingObject> _nativeObjects = SplayTreeMap();

  static BindingObject getBindingObject(Pointer<NativeBindingObject> pointer) {
    BindingObject? target = _nativeObjects[pointer.address];
    if (target == null) {
      throw FlutterError('Can not get binding object: $pointer');
    }
    return target;
  }

  static void _bindObject(BindingObject object) {
    Pointer<NativeBindingObject>? nativeBindingObject = object.pointer;
    if (nativeBindingObject != null) {
      _nativeObjects[nativeBindingObject.address] = object;
      nativeBindingObject.ref.invokeBindingMethodFromNative = _invokeBindingMethodFromNative;
    }
  }

  static void _unbindObject(BindingObject object) {
    Pointer<NativeBindingObject>? nativeBindingObject = object.pointer;
    if (nativeBindingObject != null) {
      _nativeObjects.remove(nativeBindingObject.address);
      nativeBindingObject.ref.invokeBindingMethodFromNative = nullptr;
    }
  }

  static void setup() {
    BindingObject.bind = _bindObject;
    BindingObject.unbind = _unbindObject;
  }

  static void teardown() {
    BindingObject.bind = null;
    BindingObject.unbind = null;
  }

  static void listenEvent(EventTarget target, String type) {
    assert(_debugShouldNotListenMultiTimes(target, type),
      'Failed to listen event \'$type\' for $target, for which is already bound.');
    target.addEventListener(type, _dispatchEventToNative);
  }

  static void unlistenEvent(EventTarget target, String type) {
    assert(_debugShouldNotUnlistenEmpty(target, type),
      'Failed to unlisten event \'$type\' for $target, for which is already unbound.');
    target.removeEventListener(type, _dispatchEventToNative);
  }

  static bool _debugShouldNotListenMultiTimes(EventTarget target, String type) {
    Map<String, List<EventHandler>> eventHandlers = target.getEventHandlers();
    List<EventHandler>? handlers = eventHandlers[type];
    if (handlers != null) {
      return !handlers.contains(_dispatchEventToNative);
    }
    return true;
  }

  static bool _debugShouldNotUnlistenEmpty(EventTarget target, String type) {
    Map<String, List<EventHandler>> eventHandlers = target.getEventHandlers();
    List<EventHandler>? handlers = eventHandlers[type];
    if (handlers != null) {
      return handlers.contains(_dispatchEventToNative);
    }
    return false;
  }
}
