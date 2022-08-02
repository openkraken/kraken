/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

typedef _RegisterServiceExtensionCallback = void Function({
  required String name,
  required ServiceExtensionCallback callback,
});

/// Signature for the selection change callback used by
/// [WidgetInspectorService.selectionChangedCallback].
typedef InspectorSelectionChangedCallback = void Function();

/// Structure to help reference count Dart objects referenced by a GUI tool
/// using [WidgetInspectorService].
class _InspectorReferenceData {
  _InspectorReferenceData(this.object);

  final Object object;
  int count = 1;
}

// Production implementation of [ElementInspectorService].
class _ElementInspectorService = Object with ElementInspectorService;

/// Service used by GUI tools to interact with the [WidgetInspector].
///
/// Calls to this object are typically made from GUI tools such as the [Flutter
/// IntelliJ Plugin](https://github.com/flutter/flutter-intellij/blob/master/README.md)
/// using the [Dart VM Service protocol](https://github.com/dart-lang/sdk/blob/master/runtime/vm/service/service.md).
/// This class uses its own object id and manages object lifecycles itself
/// instead of depending on the [object ids](https://github.com/dart-lang/sdk/blob/master/runtime/vm/service/service.md#getobject)
/// specified by the VM Service Protocol because the VM Service Protocol ids
/// expire unpredictably. Object references are tracked in groups so that tools
/// that clients can use dereference all objects in a group with a single
/// operation making it easier to avoid memory leaks.
///
/// All methods in this class are appropriate to invoke from debugging tools
/// using the Observatory service protocol to evaluate Dart expressions of the
/// form `WidgetInspectorService.instance.methodName(arg1, arg2, ...)`. If you
/// make changes to any instance method of this class you need to verify that
/// the [Flutter IntelliJ Plugin](https://github.com/flutter/flutter-intellij/blob/master/README.md)
/// widget inspector support still works with the changes.
///
/// All methods returning String values return JSON.
mixin ElementInspectorService {
  /// Ring of cached JSON values to prevent JSON from being garbage
  /// collected before it can be requested over the Observatory protocol.
  final List<String> _serializeRing = List<String>.filled(20, '');
  int _serializeRingIndex = 0;

  /// The current [ElementInspectorService].
  static ElementInspectorService get instance => _instance;
  static ElementInspectorService _instance = _ElementInspectorService();
  @protected
  static set instance(ElementInspectorService instance) {
    _instance = instance;
  }

  static bool _debugServiceExtensionsRegistered = false;

  /// Ground truth tracking what object(s) are currently selected used by both
  /// GUI tools such as the Flutter IntelliJ Plugin and the [WidgetInspector]
  /// displayed on the device.
  final InspectorSelection selection = InspectorSelection();

  /// Callback typically registered by the [WidgetInspector] to receive
  /// notifications when [selection] changes.
  ///
  /// The Flutter IntelliJ Plugin does not need to listen for this event as it
  /// instead listens for `dart:developer` `inspect` events which also trigger
  /// when the inspection target changes on device.
  InspectorSelectionChangedCallback? selectionChangedCallback;

  /// The Observatory protocol does not keep alive object references so this
  /// class needs to manually manage groups of objects that should be kept
  /// alive.
  final Map<String, Set<_InspectorReferenceData>> _groups = <String, Set<_InspectorReferenceData>>{};
  final Map<String, _InspectorReferenceData> _idToReferenceData = <String, _InspectorReferenceData>{};
  final Map<Object, String> _objectToId = Map<Object, String>.identity();
  int _nextId = 0;

  late _RegisterServiceExtensionCallback _registerServiceExtensionCallback;

  /// Registers a service extension method with the given name (full
  /// name "ext.flutter.inspector.name").
  ///
  /// The given callback is called when the extension method is called. The
  /// callback must return a value that can be converted to JSON using
  /// `json.encode()` (see [JsonEncoder]). The return value is stored as a
  /// property named `result` in the JSON. In case of failure, the failure is
  /// reported to the remote caller and is dumped to the logs.
  @protected
  void registerServiceExtension({
    required String name,
    required ServiceExtensionCallback callback,
  }) {
    _registerServiceExtensionCallback(
      name: 'inspector.$name',
      callback: callback,
    );
  }

  /// Registers a service extension method with the given name (full
  /// name "ext.flutter.inspector.name"), which takes no arguments.
  void _registerSignalServiceExtension({
    required String name,
    required FutureOr<dynamic> Function() callback,
  }) {
    registerServiceExtension(
      name: name,
      callback: (Map<String, String> parameters) async {
        return <String, Object>{'result': await callback()};
      },
    );
  }

  /// Registers a service extension method with the given name (full
  /// name "ext.flutter.inspector.name"), which takes a single optional argument
  /// "objectGroup" specifying what group is used to manage lifetimes of
  /// object references in the returned JSON (see [disposeGroup]).
  /// If "objectGroup" is omitted, the returned JSON will not include any object
  /// references to avoid leaking memory.
  void _registerObjectGroupServiceExtension({
    required String name,
    required FutureOr<dynamic> Function(String objectGroup) callback,
  }) {
    registerServiceExtension(
      name: name,
      callback: (Map<String, String> parameters) async {
        return <String, Object>{'result': await callback(parameters['objectGroup']!)};
      },
    );
  }

  /// Registers a service extension method with the given name (full
  /// name "ext.flutter.inspector.name"), which takes a single argument
  /// "enabled" which can have the value "true" or the value "false"
  /// or can be omitted to read the current value. (Any value other
  /// than "true" is considered equivalent to "false". Other arguments
  /// are ignored.)
  ///
  /// Calls the `getter` callback to obtain the value when
  /// responding to the service extension method being called.
  ///
  /// Calls the `setter` callback with the new value when the
  /// service extension method is called with a new value.
  void _registerBoolServiceExtension({
    required String name,
    required AsyncValueGetter<bool> getter,
    required AsyncValueSetter<bool> setter,
  }) {
    registerServiceExtension(
      name: name,
      callback: (Map<String, String> parameters) async {
        if (parameters.containsKey('enabled')) {
          final bool value = parameters['enabled'] == 'true';
          await setter(value);
          _postExtensionStateChangedEvent(name, value);
        }
        return <String, dynamic>{'enabled': await getter() ? 'true' : 'false'};
      },
    );
  }

  /// Sends an event when a service extension's state is changed.
  ///
  /// Clients should listen for this event to stay aware of the current service
  /// extension state. Any service extension that manages a state should call
  /// this method on state change.
  ///
  /// `value` reflects the newly updated service extension value.
  ///
  /// This will be called automatically for service extensions registered via
  /// [registerBoolServiceExtension].
  void _postExtensionStateChangedEvent(String name, value) {
    postEvent(
      'Flutter.ServiceExtensionStateChanged',
      <String, dynamic>{
        'extension': 'ext.flutter.inspector.$name',
        'value': value,
      },
    );
  }

  /// All events dispatched by a [WidgetInspectorService] use this method
  /// instead of calling [developer.postEvent] directly so that tests for
  /// [WidgetInspectorService] can track which events were dispatched by
  /// overriding this method.
  @protected
  void postEvent(String eventKind, Map<String, dynamic> eventData) {
    developer.postEvent(eventKind, eventData);
  }

  /// Registers a service extension method with the given name (full
  /// name "ext.flutter.inspector.name") which takes an optional parameter named
  /// "arg" and a required parameter named "objectGroup" used to control the
  /// lifetimes of object references in the returned JSON (see [disposeGroup]).
  void _registerServiceExtensionWithArg({
    required String name,
    required FutureOr<Object?> Function(String? objectId, String objectGroup) callback,
  }) {
    registerServiceExtension(
      name: name,
      callback: (Map<String, String> parameters) async {
        assert(parameters.containsKey('objectGroup'));
        return <String, Object?>{
          'result': await callback(parameters['arg'], parameters['objectGroup']!),
        };
      },
    );
  }

  static const String _consoleObjectGroup = 'console-group';

  int _errorsSinceReload = 0;

  void _reportError(FlutterErrorDetails details) {
    final Map<String, Object?> errorJson = _nodeToJson(
      details.toDiagnosticsNode(),
      InspectorSerializationDelegate(
        groupName: _consoleObjectGroup,
        subtreeDepth: 5,
        includeProperties: true,
        expandPropertyValues: true,
        maxDescendentsTruncatableNode: 5,
        service: this,
      ),
    )!;

    errorJson['errorsSinceReload'] = _errorsSinceReload;
    if (_errorsSinceReload == 0) {
      errorJson['renderedErrorText'] = TextTreeRenderer(
        wrapWidth: FlutterError.wrapWidth,
        wrapWidthProperties: FlutterError.wrapWidth,
        maxDescendentsTruncatableNode: 5,
      ).render(details.toDiagnosticsNode(style: DiagnosticsTreeStyle.error)).trimRight();
    } else {
      errorJson['renderedErrorText'] = 'Another exception was thrown: ${details.summary}';
    }

    _errorsSinceReload += 1;
    postEvent('Flutter.Error', errorJson);
  }

  /// Resets the count of errors since the last hot reload.
  ///
  /// This data is sent to clients as part of the 'Flutter.Error' service
  /// protocol event. Clients may choose to display errors received after the
  /// first error differently.
  void _resetErrorCount() {
    _errorsSinceReload = 0;
  }

  /// Called to register service extensions.
  ///
  /// See also:
  ///
  ///  * <https://github.com/dart-lang/sdk/blob/master/runtime/vm/service/service.md#rpcs-requests-and-responses>
  ///  * [BindingBase.initServiceExtensions], which explains when service
  ///    extensions can be used.
  void initServiceExtensions(_RegisterServiceExtensionCallback registerServiceExtensionCallback) {
    _registerServiceExtensionCallback = registerServiceExtensionCallback;
    assert(!_debugServiceExtensionsRegistered);
    assert(() {
      _debugServiceExtensionsRegistered = true;
      return true;
    }());

//    SchedulerBinding.instance.addPersistentFrameCallback(_onFrameStart);

    final FlutterExceptionHandler structuredExceptionHandler = _reportError;
    final FlutterExceptionHandler? defaultExceptionHandler = FlutterError.onError;

    _registerBoolServiceExtension(
      name: 'structuredErrors',
      getter: () async => FlutterError.onError == structuredExceptionHandler,
      setter: (bool value) {
        FlutterError.onError = value ? structuredExceptionHandler : defaultExceptionHandler;
        return Future<void>.value();
      },
    );

    _registerSignalServiceExtension(
      name: 'disposeAllGroups',
      callback: disposeAllGroups,
    );
    _registerObjectGroupServiceExtension(
      name: 'disposeGroup',
      callback: disposeGroup,
    );
    _registerServiceExtensionWithArg(
      name: 'disposeId',
      callback: disposeId,
    );
    _registerServiceExtensionWithArg(
      name: 'setSelectionById',
      callback: setSelectionById,
    );
    _registerServiceExtensionWithArg(
      name: 'getProperties',
      callback: _getProperties,
    );
    _registerServiceExtensionWithArg(
      name: 'getChildren',
      callback: _getChildren,
    );

    _registerServiceExtensionWithArg(
      name: 'getChildrenSummaryTree',
      callback: _getChildrenSummaryTree,
    );

    _registerServiceExtensionWithArg(
      name: 'getChildrenDetailsSubtree',
      callback: _getChildrenDetailsSubtree,
    );

    _registerObjectGroupServiceExtension(
      name: 'getRootRenderObject',
      callback: _getRootRenderObject,
    );
    registerServiceExtension(
      name: 'getDetailsSubtree',
      callback: (Map<String, String> parameters) async {
        assert(parameters.containsKey('objectGroup'));
        final String? subtreeDepth = parameters['subtreeDepth'];
        return <String, Object>{
          'result': _getDetailsSubtree(
            parameters['arg']!,
            parameters['objectGroup']!,
            subtreeDepth != null ? int.parse(subtreeDepth) : 2,
          )!,
        };
      },
    );
    _registerServiceExtensionWithArg(
      name: 'getSelectedRenderObject',
      callback: _getSelectedRenderObject,
    );
  }

  /// Clear all InspectorService object references.
  ///
  /// Use this method only for testing to ensure that object references from one
  /// test case do not impact other test cases.
  @protected
  void disposeAllGroups() {
    _groups.clear();
    _idToReferenceData.clear();
    _objectToId.clear();
    _nextId = 0;
  }

  /// Free all references to objects in a group.
  ///
  /// Objects and their associated ids in the group may be kept alive by
  /// references from a different group.
  @protected
  void disposeGroup(String name) {
    final Set<_InspectorReferenceData>? references = _groups.remove(name);
    if (references == null) return;
    references.forEach(_decrementReferenceCount);
  }

  void _decrementReferenceCount(_InspectorReferenceData reference) {
    reference.count -= 1;
    assert(reference.count >= 0);
    if (reference.count == 0) {
      final String id = _objectToId.remove(reference.object)!;
      _idToReferenceData.remove(id);
    }
  }

  /// Returns a unique id for [object] that will remain live at least until
  /// [disposeGroup] is called on [groupName] or [dispose] is called on the id
  /// returned by this method.
  @protected
  String? toId(Object? object, String groupName) {
    if (object == null) return null;

    final Set<_InspectorReferenceData> group =
        _groups.putIfAbsent(groupName, () => Set<_InspectorReferenceData>.identity());
    String? id = _objectToId[object];
    _InspectorReferenceData? referenceData;
    if (id == null) {
      id = 'inspector-$_nextId';
      _nextId += 1;
      _objectToId[object] = id;
      referenceData = _InspectorReferenceData(object);
      _idToReferenceData[id] = referenceData;
      group.add(referenceData);
    } else {
      referenceData = _idToReferenceData[id]!;
      if (group.add(referenceData)) referenceData.count += 1;
    }
    return id;
  }

  /// Returns the Dart object associated with a reference id.
  ///
  /// The `groupName` parameter is not required by is added to regularize the
  /// API surface of the methods in this class called from the Flutter IntelliJ
  /// Plugin.
  @protected
  Object? toObject(String? id, [String? groupName]) {
    if (id == null) return null;

    final _InspectorReferenceData? data = _idToReferenceData[id];
    if (data == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Id does not exist.')]);
    }
    return data.object;
  }

  /// Remove the object with the specified `id` from the specified object
  /// group.
  ///
  /// If the object exists in other groups it will remain alive and the object
  /// id will remain valid.
  @protected
  void disposeId(String? id, String? groupName) {
    if (id == null) return;

    final _InspectorReferenceData? referenceData = _idToReferenceData[id];
    if (referenceData == null) throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Id does not exist')]);
    if (_groups[groupName]?.remove(referenceData) != true)
      throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Id is not in group')]);
    _decrementReferenceCount(referenceData);
  }

  /// Set the [WidgetInspector] selection to the object matching the specified
  /// id if the object is valid object to set as the inspector selection.
  ///
  /// Returns true if the selection was changed.
  ///
  /// The `groupName` parameter is not required by is added to regularize the
  /// API surface of methods called from the Flutter IntelliJ Plugin.
  @protected
  bool setSelectionById(String? id, String? groupName) {
    return setSelection(toObject(id), groupName);
  }

  /// Set the [WidgetInspector] selection to the specified `object` if it is
  /// a valid object to set as the inspector selection.
  ///
  /// Returns true if the selection was changed.
  ///
  /// The `groupName` parameter is not needed but is specified to regularize the
  /// API surface of methods called from the Flutter IntelliJ Plugin.
  @protected
  bool setSelection(Object? object, [String? groupName]) {
    if (object is RenderObject) {
      if (object == selection.current) {
        return false;
      }
      selection.current = object;
      developer.inspect(selection.current);
      if (selectionChangedCallback != null) {
        if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
          selectionChangedCallback!();
        } else {
          // It isn't safe to trigger the selection change callback if we are in
          // the middle of rendering the frame.
          SchedulerBinding.instance.scheduleTask(
            selectionChangedCallback!,
            Priority.touch,
          );
        }
      }
      return true;
    }
    return false;
  }

  Map<String, Object?>? _nodeToJson(
    DiagnosticsNode? node,
    InspectorSerializationDelegate delegate,
  ) {
    return node?.toJsonMap(delegate);
  }

  /// Wrapper around `json.encode` that uses a ring of cached values to prevent
  /// the Dart garbage collector from collecting objects between when
  /// the value is returned over the Observatory protocol and when the
  /// separate observatory protocol command has to be used to retrieve its full
  /// contents.
  //
  // TODO(jacobr): Replace this with a better solution once
  // https://github.com/dart-lang/sdk/issues/32919 is fixed.
  String _safeJsonEncode(Object? object) {
    final String jsonString = json.encode(object);
    _serializeRing[_serializeRingIndex] = jsonString;
    _serializeRingIndex = (_serializeRingIndex + 1) % _serializeRing.length;
    return jsonString;
  }

  List<DiagnosticsNode> _truncateNodes(Iterable<DiagnosticsNode> nodes, int maxDescendentsTruncatableNode) {
//    if (nodes.every((DiagnosticsNode node) => node.value is Element)) {
//      final List<DiagnosticsNode> localNodes = nodes.where((DiagnosticsNode node) =>
//          _isValueCreatedByLocalProject(node.value)).toList();
//      if (localNodes.isNotEmpty) {
//        return localNodes;
//      }
//    }
    return nodes.take(maxDescendentsTruncatableNode).toList();
  }

  List<Map<String, Object?>> _nodesToJson(
    List<DiagnosticsNode> nodes,
    InspectorSerializationDelegate delegate, {
    required DiagnosticsNode? parent,
  }) {
    return DiagnosticsNode.toJsonList(nodes, parent, delegate);
  }

  /// Returns a JSON representation of the properties of the [DiagnosticsNode]
  /// object that `diagnosticsNodeId` references.
  @protected
  String getProperties(String diagnosticsNodeId, String groupName) {
    return _safeJsonEncode(_getProperties(diagnosticsNodeId, groupName));
  }

  List<Object> _getProperties(String? diagnosticsNodeId, String? groupName) {
    final DiagnosticsNode? node = toObject(diagnosticsNodeId) as DiagnosticsNode;
    return _nodesToJson(node == null ? const <DiagnosticsNode>[] : node.getProperties(),
        InspectorSerializationDelegate(groupName: groupName, service: this),
        parent: node);
  }

  /// Returns a JSON representation of the children of the [DiagnosticsNode]
  /// object that `diagnosticsNodeId` references.
  String getChildren(String diagnosticsNodeId, String groupName) {
    return _safeJsonEncode(_getChildren(diagnosticsNodeId, groupName));
  }

  List<Object> _getChildren(String? diagnosticsNodeId, String? groupName) {
    final DiagnosticsNode node = toObject(diagnosticsNodeId) as DiagnosticsNode;
    final InspectorSerializationDelegate delegate = InspectorSerializationDelegate(groupName: groupName, service: this);
    return _nodesToJson(_getChildrenFiltered(node, delegate), delegate, parent: node);
  }

  /// Returns a JSON representation of the children of the [DiagnosticsNode]
  /// object that `diagnosticsNodeId` references only including children that
  /// were created directly by user code.
  ///
  /// Requires [Widget] creation locations which are only available for debug
  /// mode builds when the `--track-widget-creation` flag is passed to
  /// `flutter_tool`.
  ///
  /// See also:
  ///
  ///  * [isWidgetCreationTracked] which indicates whether this method can be
  ///    used.
  String getChildrenSummaryTree(String diagnosticsNodeId, String groupName) {
    return _safeJsonEncode(_getChildrenSummaryTree(diagnosticsNodeId, groupName));
  }

  List<Object> _getChildrenSummaryTree(String? diagnosticsNodeId, String? groupName) {
    final DiagnosticsNode node = toObject(diagnosticsNodeId) as DiagnosticsNode;
    final InspectorSerializationDelegate delegate =
        InspectorSerializationDelegate(groupName: groupName, summaryTree: true, service: this);
    return _nodesToJson(_getChildrenFiltered(node, delegate), delegate, parent: node);
  }

  /// Returns a JSON representation of the children of the [DiagnosticsNode]
  /// object that `diagnosticsNodeId` references providing information needed
  /// for the details subtree view.
  ///
  /// The details subtree shows properties inline and includes all children
  /// rather than a filtered set of important children.
  String getChildrenDetailsSubtree(String diagnosticsNodeId, String groupName) {
    return _safeJsonEncode(_getChildrenDetailsSubtree(diagnosticsNodeId, groupName));
  }

  List<Object> _getChildrenDetailsSubtree(String? diagnosticsNodeId, String? groupName) {
    final DiagnosticsNode node = toObject(diagnosticsNodeId) as DiagnosticsNode;
    // With this value of minDepth we only expand one extra level of important nodes.
    final InspectorSerializationDelegate delegate =
        InspectorSerializationDelegate(groupName: groupName, subtreeDepth: 1, includeProperties: true, service: this);
    return _nodesToJson(_getChildrenFiltered(node, delegate), delegate, parent: node);
  }

  bool _shouldShowInSummaryTree(DiagnosticsNode node) {
    if (node.level == DiagnosticLevel.error) {
      return true;
    }
    final Object? value = node.value;
    if (value is! Diagnosticable) {
      return true;
    }
    return false;
  }

  List<DiagnosticsNode> _getChildrenFiltered(
    DiagnosticsNode node,
    InspectorSerializationDelegate delegate,
  ) {
    return _filterChildren(node.getChildren(), delegate);
  }

  List<DiagnosticsNode> _filterChildren(
    List<DiagnosticsNode> nodes,
    InspectorSerializationDelegate delegate,
  ) {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[
      for (DiagnosticsNode child in nodes)
        if (!delegate.summaryTree || _shouldShowInSummaryTree(child))
          child
        else
          ..._getChildrenFiltered(child, delegate),
    ];
    return children;
  }

  /// Returns a JSON representation of the [DiagnosticsNode] for the root
  /// [RenderObject].
  @protected
  String getRootRenderObject(String groupName) {
    return _safeJsonEncode(_getRootRenderObject(groupName));
  }

  Map<String, Object?>? _getRootRenderObject(String groupName) {
    return _nodeToJson(RendererBinding.instance.renderView.toDiagnosticsNode(),
        InspectorSerializationDelegate(groupName: groupName, service: this));
  }

  /// Returns a JSON representation of the subtree rooted at the
  /// [DiagnosticsNode] object that `diagnosticsNodeId` references providing
  /// information needed for the details subtree view.
  ///
  /// The number of levels of the subtree that should be returned is specified
  /// by the [subtreeDepth] parameter. This value defaults to 2 for backwards
  /// compatibility.
  ///
  /// See also:
  ///
  ///  * [getChildrenDetailsSubtree], a method to get children of a node
  ///    in the details subtree.
  String getDetailsSubtree(
    String id,
    String groupName, {
    int subtreeDepth = 2,
  }) {
    return _safeJsonEncode(_getDetailsSubtree(id, groupName, subtreeDepth)!);
  }

  Map<String, Object?>? _getDetailsSubtree(
    String id,
    String groupName,
    int subtreeDepth,
  ) {
    final DiagnosticsNode? root = toObject(id) as DiagnosticsNode?;
    if (root == null) {
      return null;
    }
    return _nodeToJson(
      root,
      InspectorSerializationDelegate(
        groupName: groupName,
        summaryTree: false,
        subtreeDepth: subtreeDepth,
        includeProperties: true,
        service: this,
      ),
    );
  }

  /// Returns a [DiagnosticsNode] representing the currently selected
  /// [RenderObject].
  ///
  /// If the currently selected [RenderObject] is identical to the
  /// [RenderObject] referenced by `previousSelectionId` then the previous
  /// [DiagnosticsNode] is reused.
  @protected
  String getSelectedRenderObject(String previousSelectionId, String groupName) {
    return _safeJsonEncode(_getSelectedRenderObject(previousSelectionId, groupName));
  }

  Map<String, Object?>? _getSelectedRenderObject(String? previousSelectionId, String groupName) {
    final DiagnosticsNode? previousSelection = toObject(previousSelectionId) as DiagnosticsNode?;
    final RenderObject? current = selection.current;
    return _nodeToJson(current == previousSelection?.value ? previousSelection : current?.toDiagnosticsNode(),
        InspectorSerializationDelegate(groupName: groupName, service: this));
  }

  /// This method is called by [WidgetBinding.performReassemble] to flush caches
  /// of obsolete values after a hot reload.
  ///
  /// Do not call this method directly. Instead, use
  /// [BindingBase.reassembleApplication].
  void performReassemble() {
    _resetErrorCount();
  }
}

/// Mutable selection state of the inspector.
class InspectorSelection {
  /// Render objects that are candidates to be selected.
  ///
  /// Tools may wish to iterate through the list of candidates.
  List<RenderObject> get candidates => _candidates;
  List<RenderObject> _candidates = <RenderObject>[];
  set candidates(List<RenderObject> value) {
    _candidates = value;
    _index = 0;
    _computeCurrent();
  }

  /// Index within the list of candidates that is currently selected.
  int get index => _index;
  int _index = 0;
  set index(int value) {
    _index = value;
    _computeCurrent();
  }

  /// Set the selection to empty.
  void clear() {
    _candidates = <RenderObject>[];
    _index = 0;
    _computeCurrent();
  }

  /// Selected render object typically from the [candidates] list.
  ///
  /// Setting [candidates] or calling [clear] resets the selection.
  ///
  /// Returns null if the selection is invalid.
  RenderObject? get current => active ? _current : null;

  RenderObject? _current;
  set current(RenderObject? value) {
    if (_current != value) {
      _current = value;
    }
  }

  void _computeCurrent() {
    if (_index < candidates.length) {
      _current = candidates[index];
    } else {
      _current = null;
    }
  }

  /// Whether the selected render object is attached to the tree or has gone
  /// out of scope.
  bool get active => _current != null && _current!.attached;
}

/// A delegate that configures how a hierarchy of [DiagnosticsNode]s are
/// serialized by the Flutter Inspector.
@visibleForTesting
class InspectorSerializationDelegate implements DiagnosticsSerializationDelegate {
  /// Creates an [InspectorSerializationDelegate] that serialize [DiagnosticsNode]
  /// for Flutter Inspector service.
  InspectorSerializationDelegate({
    this.groupName,
    this.summaryTree = false,
    this.maxDescendentsTruncatableNode = -1,
    this.expandPropertyValues = true,
    this.subtreeDepth = 1,
    this.includeProperties = false,
    required this.service,
    this.addAdditionalPropertiesCallback,
  });

  /// Service used by GUI tools to interact with the [WidgetInspector].
  final ElementInspectorService service;

  /// Optional `groupName` parameter which indicates that the json should
  /// contain live object ids.
  ///
  /// Object ids returned as part of the json will remain live at least until
  /// [WidgetInspectorService.disposeGroup()] is called on [groupName].
  final String? groupName;

  /// Whether the tree should only include nodes created by the local project.
  final bool summaryTree;

  /// Maximum descendents of [DiagnosticsNode] before truncating.
  final int maxDescendentsTruncatableNode;

  @override
  final bool includeProperties;

  @override
  final int subtreeDepth;

  @override
  final bool expandPropertyValues;

  /// Callback to add additional experimental serialization properties.
  ///
  /// This callback can be used to customize the serialization of DiagnosticsNode
  /// objects for experimental features in widget inspector clients such as
  /// [Dart DevTools](https://github.com/flutter/devtools).
  /// For example, [Dart DevTools](https://github.com/flutter/devtools)
  /// can evaluate the following expression to register a VM Service API
  /// with a custom serialization to experiment with visualizing layouts.
  ///
  /// The following code samples demonstrates adding the [RenderObject] associated
  /// with an [Element] to the serialized data for all elements in the tree:
  ///
  /// ```dart
  /// Map<String, Object> getDetailsSubtreeWithRenderObject(
  ///   String id,
  ///   String groupName,
  ///   int subtreeDepth,
  /// ) {
  ///   return _nodeToJson(
  ///     root,
  ///     InspectorSerializationDelegate(
  ///       groupName: groupName,
  ///       summaryTree: false,
  ///       subtreeDepth: subtreeDepth,
  ///       includeProperties: true,
  ///       service: this,
  ///       addAdditionalPropertiesCallback: (DiagnosticsNode node, _SerializationDelegate delegate) {
  ///         final Map<String, Object> additionalJson = <String, Object>{};
  ///         final Object value = node.value;
  ///         if (value is Element) {
  ///           final renderObject = value.renderObject;
  ///           additionalJson['renderObject'] = renderObject?.toDiagnosticsNode()?.toJsonMap(
  ///             delegate.copyWith(
  ///               subtreeDepth: 0,
  ///               includeProperties: true,
  ///             ),
  ///           );
  ///         }
  ///         return additionalJson;
  ///       },
  ///     ),
  ///  );
  /// }
  /// ```
  final Map<String, Object> Function(DiagnosticsNode, InspectorSerializationDelegate)? addAdditionalPropertiesCallback;

  final List<DiagnosticsNode> _nodesCreatedByLocalProject = <DiagnosticsNode>[];

  bool get _interactive => groupName != null;

  @override
  Map<String, Object?> additionalNodeProperties(DiagnosticsNode node) {
    final Map<String, Object?> result = <String, Object?>{};
    final Object? value = node.value;
    if (_interactive) {
      result['objectId'] = service.toId(node, groupName!);
      result['valueId'] = service.toId(value, groupName!);
    }
    if (summaryTree) {
      result['summaryTree'] = true;
    }
    if (addAdditionalPropertiesCallback != null) {
      result.addAll(addAdditionalPropertiesCallback!(node, this));
    }
    return result;
  }

  @override
  DiagnosticsSerializationDelegate delegateForNode(DiagnosticsNode node) {
    // The tricky special case here is that when in the detailsTree,
    // we keep subtreeDepth from going down to zero until we reach nodes
    // that also exist in the summary tree. This ensures that every time
    // you expand a node in the details tree, you expand the entire subtree
    // up until you reach the next nodes shared with the summary tree.
    return summaryTree || subtreeDepth > 1 || service._shouldShowInSummaryTree(node)
        ? copyWith(subtreeDepth: subtreeDepth - 1)
        : this;
  }

  @override
  List<DiagnosticsNode> filterChildren(List<DiagnosticsNode> children, DiagnosticsNode owner) {
    return service._filterChildren(children, this);
  }

  @override
  List<DiagnosticsNode> filterProperties(List<DiagnosticsNode> properties, DiagnosticsNode owner) {
    final bool createdByLocalProject = _nodesCreatedByLocalProject.contains(owner);
    return properties.where((DiagnosticsNode node) {
      return !node.isFiltered(createdByLocalProject ? DiagnosticLevel.fine : DiagnosticLevel.info);
    }).toList();
  }

  @override
  List<DiagnosticsNode> truncateNodesList(List<DiagnosticsNode> nodes, DiagnosticsNode? owner) {
    if (maxDescendentsTruncatableNode >= 0 &&
        owner?.allowTruncate == true &&
        nodes.length > maxDescendentsTruncatableNode) {
      nodes = service._truncateNodes(nodes, maxDescendentsTruncatableNode);
    }
    return nodes;
  }

  @override
  DiagnosticsSerializationDelegate copyWith({int? subtreeDepth, bool? includeProperties}) {
    return InspectorSerializationDelegate(
      groupName: groupName,
      summaryTree: summaryTree,
      maxDescendentsTruncatableNode: maxDescendentsTruncatableNode,
      expandPropertyValues: expandPropertyValues,
      subtreeDepth: subtreeDepth ?? this.subtreeDepth,
      includeProperties: includeProperties ?? this.includeProperties,
      service: service,
      addAdditionalPropertiesCallback: addAdditionalPropertiesCallback,
    );
  }
}
