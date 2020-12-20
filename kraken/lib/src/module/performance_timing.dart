import 'dart:collection';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:kraken/bridge.dart';

const String PERF_CONTROLLER_INIT_START = 'kraken_controller_init_start';
const String PERF_CONTROLLER_INIT_END = 'kraken_controller_init_end';
const String PERF_CONTROLLER_PROPERTY_INIT = 'kraken_controller_properties_init';
const String PERF_VIEW_CONTROLLER_INIT_START = 'kraken_view_controller_init_start';
const String PERF_VIEW_CONTROLLER_INIT_END = 'kraken_view_controller_init_end';
const String PERF_VIEW_CONTROLLER_PROPERTY_INIT = 'kraken_view_controller_property_init';
const String PERF_BRIDGE_INIT_START = 'kraken_bridge_init_start';
const String PERF_BRIDGE_INIT_END = 'kraken_bridge_init_end';
const String PERF_BRIDGE_REGISTER_DART_METHOD_START = 'kraken_bridge_register_dart_method_start';
const String PERF_BRIDGE_REGISTER_DART_METHOD_END = 'kraken_bridge_register_dart_method_end';
const String PERF_CREATE_VIEWPORT_START = 'kraken_create_viewport_start';
const String PERF_CREATE_VIEWPORT_END = 'kraken_create_viewport_end';
const String PERF_ELEMENT_MANAGER_INIT_START = 'kraken_element_manager_init_start';
const String PERF_ELEMENT_MANAGER_INIT_END = 'kraken_element_manager_init_end';
const String PERF_ELEMENT_MANAGER_PROPERTY_INIT = 'kraken_element_manager_property_init';
const String PERF_BODY_ELEMENT_INIT_START = 'kraken_body_element_init_start';
const String PERF_BODY_ELEMENT_INIT_END = 'kraken_body_element_init_end';
const String PERF_BODY_ELEMENT_PROPERTY_INIT = 'kraken_body_element_property_init';
const String PERF_JS_BUNDLE_LOAD_START = 'kraken_js_bundle_load_start';
const String PERF_JS_BUNDLE_LOAD_END = 'kraken_js_bundle_load_end';
const String PERF_JS_BUNDLE_EVAL_START = 'kraken_js_bundle_eval_start';
const String PERF_JS_BUNDLE_EVAL_END = 'kraken_js_bundle_eval_end';
const String PERF_FLUSH_UI_COMMAND_START = 'kraken_flush_ui_command_start';
const String PERF_FLUSH_UI_COMMAND_END = 'kraken_flush_ui_command_end';
const String PERF_CREATE_ELEMENT_START = 'kraken_create_element_start';
const String PERF_CREATE_ELEMENT_END = 'kraken_create_element_end';
const String PERF_CREATE_TEXT_NODE_START = 'kraken_create_text_node_start';
const String PERF_CREATE_TEXT_NODE_END = 'kraken_create_text_node_end';
const String PERF_CREATE_COMMENT_START = 'kraken_create_comment_start';
const String PERF_CREATE_COMMENT_END = 'kraken_create_comment_end';
const String PERF_DISPOSE_EVENT_TARGET_START = 'kraken_dispose_event_target_start';
const String PERF_DISPOSE_EVENT_TARGET_END = 'kraken_dispose_event_target_end';
const String PERF_ADD_EVENT_START = 'kraken_add_event_start';
const String PERF_ADD_EVENT_END = 'kraken_add_event_end';
const String PERF_INSERT_ADJACENT_NODE_START = 'kraken_insert_adjacent_node_start';
const String PERF_INSERT_ADJACENT_NODE_END = 'kraken_insert_adjacent_node_end';
const String PERF_REMOVE_NODE_START = 'kraken_remove_node_start';
const String PERF_REMOVE_NODE_END = 'kraken_remove_node_end';
const String PERF_SET_STYLE_START = 'kraken_set_style_start';
const String PERF_SET_STYLE_END = 'kraken_set_style_end';

class PerformanceEntry {
  PerformanceEntry(this.name, this.entryType, this.startTime, this.duration);

  final String name;
  final String entryType;
  final int startTime;
  final int duration;
}

class PerformanceTiming {
  static SplayTreeMap<int, PerformanceTiming> _instanceMap = SplayTreeMap();

  static PerformanceTiming instance(int contextId) {
    if (!_instanceMap.containsKey(contextId)) {
      _instanceMap[contextId] = PerformanceTiming();
    }
    return _instanceMap[contextId];
  }

  int entriesSize = 0;

  void mark(String name, [int startTime]) {
    if (startTime == null) {
      startTime = DateTime.now().microsecondsSinceEpoch;
    }

    PerformanceEntry entry = PerformanceEntry(name, 'mark', startTime, 0);
    entries[entriesSize++] = entry;
  }

  Pointer<NativePerformanceEntryList> toNative() {
    Pointer<NativePerformanceEntryList> list = allocate<NativePerformanceEntryList>();

    Uint64List data = Uint64List(entriesSize * 2);

    for (int i = 0; i < entriesSize * 2; i += 2) {
      data[i] = Utf8.toUtf8(entries[i ~/ 2].name).address;
      data[i + 1] = entries[i ~/ 2].startTime.toInt();
    }

    final Pointer<Uint64> bytes = allocate<Uint64>(count: entriesSize * 2);
    final Uint64List buffer = bytes.asTypedList(entriesSize * 2);
    buffer.setAll(0, data);

    list.ref.length = entriesSize;
    list.ref.entries = bytes;

    return list;
  }

  // Pre allocate big list for better performance.
  List<PerformanceEntry> entries = List.filled(1000000, null, growable: true);
}
