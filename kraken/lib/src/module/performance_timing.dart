import 'dart:collection';
import 'dart:ffi';
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

class PerformanceEntry {
  PerformanceEntry(this.name, this.entryType, this.startTime, this.duration);

  final String name;
  final String entryType;
  final double startTime;
  final double duration;
}

class PerformanceTiming {
  static SplayTreeMap<int, PerformanceTiming> _instanceMap = SplayTreeMap();

  static PerformanceTiming instance(int contextId) {
    if (!_instanceMap.containsKey(contextId)) {
      _instanceMap[contextId] = PerformanceTiming();
    }
    return _instanceMap[contextId];
  }

  void mark(String name, [double startTime]) {
    if (startTime == null) {
      startTime = DateTime.now().microsecondsSinceEpoch.toDouble();
    }

    PerformanceEntry entry = PerformanceEntry(name, 'mark', startTime, 0);
    entries.add(entry);
  }

  Pointer<NativePerformanceEntryList> toNative() {
    Pointer<NativePerformanceEntryList> list = allocate<NativePerformanceEntryList>();
    Pointer<Pointer<NativePerformanceEntry>> nativeEntries =
        allocate<NativePerformanceEntry>(count: entries.length).cast<Pointer<NativePerformanceEntry>>();

    for (int i = 0; i < entries.length; i ++) {
      Pointer<NativePerformanceEntry> nativeEntry = allocate<NativePerformanceEntry>();
      nativeEntry.ref.name = Utf8.toUtf8(entries[i].name);
      nativeEntry.ref.entryType = Utf8.toUtf8(entries[i].entryType);
      nativeEntry.ref.startTime = entries[i].startTime;
      nativeEntry.ref.duration = entries[i].duration;
      nativeEntries[i] = nativeEntry;
    }

    list.ref.length = entries.length;
    list.ref.entries = nativeEntries;
    return list;
  }

  List<PerformanceEntry> entries = List();
}
