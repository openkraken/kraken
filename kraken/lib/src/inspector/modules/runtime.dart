import 'dart:async';
import 'dart:convert';

import 'package:kraken/inspector.dart';
import 'package:kraken/dom.dart';
import '../module.dart';

class ExecutionContextDescription extends JSONEncodable {
  // Unique id of the execution context. It can be used to specify in which execution context script evaluation should be performed.
  final int id;

  // Execution context origin.
  final String origin;

  // Human readable name describing given context.
  final String name;

  // A system-unique execution context identifier. Unlike the id, this is unique accross multiple processes,
  // so can be reliably used to identify specific context while backend performs a cross-process navigation.
  final String uniqueId;

  final dynamic auxData;

  ExecutionContextDescription(this.id, this.origin, this.name, this.uniqueId, [this.auxData]);

  @override
  Map toJson() {
    Map map = {
      'id': id,
      'origin': origin,
      'name': name,
      'uniqueId': uniqueId
    };

    if (auxData != null) {
      map['auxData'] = auxData;
    }
    return map;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

// Issued when new execution context is created.
class ExecutionContextCreatedEvent extends InspectorEvent {
  String get method => 'Runtime.executionContextCreated';

  JSONEncodable get params => JSONEncodableMap({
    'context': _contextDescription
  });

  final ExecutionContextDescription _contextDescription;

  ExecutionContextCreatedEvent(this._contextDescription);
}

class PropertyPreview extends JSONEncodable {
  // Property name.
  final String name;

  // Object type. Accessor means that the property itself is an accessor property.
  // Allowed Values: object, function, undefined, string, number, boolean, symbol, accessor, bigint
  final String type;

  // User-friendly property value string.
  String value;

  // Nested value preview.
  ObjectPreview valuePreview;

  // Object subtype hint. Specified for object type values only.
  // Allowed Values: array, null, node, regexp, date, map, set, weakmap, weakset, iterator, generator, error, proxy, promise, typedarray, arraybuffer, dataview, webassemblymemory, wasmvalue
  String subtype;

  PropertyPreview(this.name, this.type, {this.value, this.valuePreview, this.subtype});

  @override
  Map toJson() {
    Map map = {
      'name': name,
      'type': type
    };
    if (value != null) map['value'] = value;
    if (valuePreview != null) map['valuePreview'] = valuePreview;
    if (subtype != null) map['subtype'] = subtype;
    return map;
  }
}

class EntryPreview extends JSONEncodable {
  // Preview of the key. Specified for map-like collection entries.
  ObjectPreview key;

  // Preview of the value.
  final ObjectPreview value;

  EntryPreview(this.value, {this.key});

  @override
  Map toJson() {
    Map map = {
      'value': value,
    };
    if (key != null) map['key'] = key;
    return map;
  }
}

// Object containing abbreviated remote object value.
class ObjectPreview extends JSONEncodable {
  // Object type.
  // Allowed Values: object, function, undefined, string, number, boolean, symbol, bigint
  final String type;

  // Object subtype hint. Specified for object type values only.
  // Allowed Values: array, null, node, regexp, date, map, set, weakmap, weakset, iterator, generator, error, proxy, promise, typedarray, arraybuffer, dataview, webassemblymemory, wasmvalue
  String subtype;

  // String representation of the object.
  String description;

  // True iff some of the properties or entries of the original object did not fit.
  final bool overflow;

  // List of the properties.
  final List<PropertyPreview> properties;

  // List of the entries. Specified for map and set subtype values only.
  List<EntryPreview> entries;

  ObjectPreview(this.type, this.overflow, this.properties, {this.subtype, this.description, this.entries});

  @override
  Map toJson() {
    Map map = {
      'type': type,
      'overflow': overflow,
      'properties': properties,
    };
    if (subtype != null) map['subtype'] = subtype;
    if (description != null) map['description'] = description;
    if (entries != null) map['entries'] = entries;
    return map;
  }
}

class CustomPreview extends JSONEncodable {
  // The JSON-stringified result of formatter.header(object, config) call. It contains json ML array that represents RemoteObject.
  final String header;

  // If formatter returns true as a result of formatter.hasBody call then bodyGetterId will contain RemoteObjectId for the function that returns result of formatter.body(object, config) call. The result value is json ML array.
  String bodyGetterId;

  CustomPreview(this.header, {this.bodyGetterId});

  @override
  Map toJson() {
    Map map = {
      'header': header
    };
    if (bodyGetterId != null) map['bodyGetterId'] = bodyGetterId;
    return map;
  }
}

// Mirror object referencing original JavaScript object.
class RemoteObject extends JSONEncodable {
  // Object type.
  // Allowed Values: object, function, undefined, string, number, boolean, symbol, bigint
  final String type;

  // Object subtype hint. Specified for object type values only. NOTE: If you change anything here, make sure to also update subtype in ObjectPreview and PropertyPreview below.
  // Allowed Values: array, null, node, regexp, date, map, set, weakmap, weakset, iterator, generator, error, proxy, promise, typedarray, arraybuffer, dataview, webassemblymemory, wasmvalue
  String subtype;

  // Object class (constructor) name. Specified for object type values only.
  String className;

  // Remote object value in case of primitive values or JSON values (if it was requested).
  dynamic value;

  // Primitive value which can not be JSON-stringified does not have value, but gets this property.
  String unserializableValue;

  // String representation of the object.
  String description;

  // Unique object identifier (for non-primitive values).
  int objectId;

  // Preview containing abbreviated property values. Specified for object type values only.
  ObjectPreview preview;

  RemoteObject(this.type, {this.subtype, this.className, this.value, this.unserializableValue, this.description, this.objectId, this.preview});

  @override
  Map toJson() {
    Map<String, dynamic> map = {
      'type': type
    };
    if (subtype != null) map['subtype'] = subtype;
    if (className != null) map['className'] = className;
    if (value != null) map['value'] = value;
    if (unserializableValue != null) map['unserializableValue'] = unserializableValue;
    if (description != null) map['description'] = description;
    if (objectId != null) map['objectId'] = objectId;
    if (preview != null) map['preview'] = preview;
    return map;
  }
}

class StackTrace extends JSONEncodable {
  Map toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class ConsoleAPICalledEvent extends InspectorEvent {
  @override
  String get method => 'Runtime.consoleAPICalled';

  @override
  JSONEncodable get params {
    Map<String, dynamic> map = {
      'type': type,
      'args': args,
      'executionContextId': executionContextId,
      'timestamp': timestamp
    };

    // if (stackTrace != null) map['stackTrace'] = stackTrace;
    // if (context != null) map['context'] = context;
    return JSONEncodableMap(map);
  }

  // Object type.
  // Allowed Values: object, function, undefined, string, number, boolean, symbol, bigint
  // Required
  final String type;

  // Call arguments.
  // Required
  final List<RemoteObject> args;

  // Identifier of the context where the call was made.
  final int executionContextId;

  // Call timestamp.
  final int timestamp;

  // Stack trace captured when the call was made.
  // The async stack chain is automatically reported for the following call types: assert, error, trace, warning.
  // For other types the async call chain can be retrieved using Debugger.getStackTrace and stackTrace.parentId field.
  // Optional
  StackTrace stackTrace;

  // Console context descriptor for calls on non-default console context (not console.*):
  // 'anonymous#unique-logger-id' for call on unnamed context, 'name#unique-logger-id' for call on named context.
  // Optional
  String context;

  ConsoleAPICalledEvent(this.type, this.args, this.executionContextId, this.timestamp);
}

class InspectRuntimeModule extends InspectModule {
  final Inspector inspector;

  ElementManager get elementManager => inspector.elementManager;

  InspectRuntimeModule(this.inspector);

  @override
  String get name => 'Runtime';

  @override
  void receiveFromFrontend(int id, String method, Map<String, dynamic> params) {
    switch (method) {
      case 'enable':
        enable();
        break;
      case 'runIfWaitingForDebugger':
        sendToFrontend(id, null);
        break;
      case 'getIsolateId':
        onGetIsolateId(id, params);
        break;
    }
  }

  void enable() {
    ExecutionContextCreatedEvent event = ExecutionContextCreatedEvent(ExecutionContextDescription(
      inspector.elementManager.contextId,
      'kraken://',
      'Main',
      'Main'
      // inspector.elementManager.controller.name,
      // inspector.elementManager.controller.name
    ));
    sendEventToFrontend(event);
    ConsoleAPICalledEvent welcome = ConsoleAPICalledEvent('log', [RemoteObject('string', value: '1234')], inspector.elementManager.contextId, DateTime.now().millisecondsSinceEpoch);
    sendEventToFrontend(welcome);
  }

  void onGetIsolateId(int id, Map<String, dynamic> params) {
    sendToFrontend(id, JSONEncodableMap({ 'id': inspector.elementManager.contextId }));
  }
}
