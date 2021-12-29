/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_PERFORMANCE_H
#define KRAKENBRIDGE_PERFORMANCE_H

#if ENABLE_PROFILE
#define PERF_WIDGET_CREATION_COST "widget_creation_cost"
#define PERF_CONTROLLER_PROPERTIES_INIT_COST "controller_properties_init_cost"
#define PERF_VIEW_CONTROLLER_PROPERTIES_INIT_COST "view_controller_properties_init_cost"
#define PERF_BRIDGE_INIT_COST "bridge_init_cost"
#define PERF_BRIDGE_REGISTER_DART_METHOD_COST "bridge_register_dart_method_cost"
#define PERF_CREATE_VIEWPORT_COST "create_viewport"
#define PERF_ELEMENT_MANAGER_INIT_COST "element_manager_init_cost"
#define PERF_ELEMENT_MANAGER_PROPERTIES_INIT_COST "element_manager_property_init_cost"
#define PERF_ROOT_ELEMENT_INIT_COST "root_element_init_cost"
#define PERF_ROOT_ELEMENT_PROPERTIES_INIT_COST "root_element_property_init_cost"
#define PERF_JS_CONTEXT_INIT_COST "js_context_init_cost"
#define PERF_JS_NATIVE_METHOD_INIT_COST "native_method_init_cost"
#define PERF_JS_POLYFILL_INIT_COST "polyfill_init_cost"
#define PERF_JS_BUNDLE_LOAD_COST "js_bundle_load_cost"
#define PERF_JS_BUNDLE_EVAL_COST "js_bundle_eval_cost"
#define PERF_JS_PARSE_TIME_COST "js_parse_time_cost"
#define PERF_JS_HOST_CLASS_INIT_COST "js_host_class_init_cost"
#define PERF_JS_NATIVE_FUNCTION_CALL_COST "js_native_function_call_cost"
#define PERF_JS_HOST_CLASS_GET_PROPERTY_COST "js_host_class_get_property_cost"
#define PERF_JS_HOST_CLASS_SET_PROPERTY_COST "js_host_class_set_property_cost"
#define PERF_FLUSH_UI_COMMAND_COST "flush_ui_command_cost"
#define PERF_CREATE_ELEMENT_COST "create_element_cost"
#define PERF_CREATE_TEXT_NODE_COST "create_text_node_cost"
#define PERF_CREATE_COMMENT_COST "create_comment_cost"
#define PERF_DISPOSE_EVENT_TARGET_COST "dispose_event_target_cost"
#define PERF_ADD_EVENT_COST "add_event_cost"
#define PERF_INSERT_ADJACENT_NODE_COST "insert_adjacent_node_cost"
#define PERF_REMOVE_NODE_COST "remove_node_cost"
#define PERF_SET_STYLE_COST "set_style_cost"
#define PERF_DOM_FORCE_LAYOUT_COST "dom_force_layout_cost"
#define PERF_DOM_FLUSH_UI_COMMAND_COST "dom_flush_ui_command_cost"
#define PERF_SET_PROPERTIES_COST "set_properties_cost"
#define PERF_REMOVE_PROPERTIES_COST "remove_properties_cost"
#define PERF_FLEX_LAYOUT_COST "flex_layout_cost"
#define PERF_FLOW_LAYOUT_COST "flow_layout_cost"
#define PERF_INTRINSIC_LAYOUT_COST "intrinsic_layout_cost"
#define PERF_SILVER_LAYOUT_COST "silver_layout_cost"
#define PERF_PAINT_COST "paint_cost"

#define PERF_CONTROLLER_INIT_START "controller_init_start"
#define PERF_CONTROLLER_INIT_END "controller_init_end"
#define PERF_CONTROLLER_PROPERTY_INIT "controller_properties_init"
#define PERF_VIEW_CONTROLLER_INIT_START "view_controller_init_start"
#define PERF_VIEW_CONTROLLER_PROPERTY_INIT "view_controller_property_init"
#define PERF_BRIDGE_INIT_START "bridge_init_start"
#define PERF_BRIDGE_INIT_END "bridge_init_end"
#define PERF_BRIDGE_REGISTER_DART_METHOD_START "bridge_register_dart_method_start"
#define PERF_BRIDGE_REGISTER_DART_METHOD_END "bridge_register_dart_method_end"
#define PERF_CREATE_VIEWPORT_START "create_viewport_start"
#define PERF_CREATE_VIEWPORT_END "create_viewport_end"
#define PERF_ELEMENT_MANAGER_INIT_START "element_manager_init_start"
#define PERF_ELEMENT_MANAGER_INIT_END "element_manager_init_end"
#define PERF_ELEMENT_MANAGER_PROPERTY_INIT "element_manager_property_init"
#define PERF_ROOT_ELEMENT_INIT_START "root_element_init_start"
#define PERF_ROOT_ELEMENT_INIT_END "root_element_init_end"
#define PERF_ROOT_ELEMENT_PROPERTY_INIT "root_element_property_init"
#define PERF_JS_CONTEXT_INIT_START "js_context_start"
#define PERF_JS_CONTEXT_INIT_END "js_context_end"
#define PERF_JS_HOST_CLASS_GET_PROPERTY_START "js_host_class_get_property_start"
#define PERF_JS_HOST_CLASS_GET_PROPERTY_END "js_host_class_get_property_end"
#define PERF_JS_HOST_CLASS_SET_PROPERTY_START "js_host_class_set_property_start"
#define PERF_JS_HOST_CLASS_SET_PROPERTY_END "js_host_class_set_property_end"
#define PERF_JS_HOST_CLASS_INIT_START "js_host_class_init_start"
#define PERF_JS_HOST_CLASS_INIT_END "js_host_class_init_end"
#define PERF_JS_NATIVE_FUNCTION_CALL_START "js_native_function_call_start"
#define PERF_JS_NATIVE_FUNCTION_CALL_END "js_native_function_call_end"
#define PERF_JS_NATIVE_METHOD_INIT_START "init_native_method_start"
#define PERF_JS_NATIVE_METHOD_INIT_END "init_native_method_end"
#define PERF_JS_POLYFILL_INIT_START "init_js_polyfill_start"
#define PERF_JS_POLYFILL_INIT_END "init_js_polyfill_end"
#define PERF_JS_BUNDLE_LOAD_START "js_bundle_load_start"
#define PERF_JS_BUNDLE_LOAD_END "js_bundle_load_end"
#define PERF_JS_BUNDLE_EVAL_START "js_bundle_eval_start"
#define PERF_JS_BUNDLE_EVAL_END "js_bundle_eval_end"
#define PERF_JS_PARSE_TIME_START "js_parse_time_start"
#define PERF_JS_PARSE_TIME_END "js_parse_time_end"
#define PERF_FLUSH_UI_COMMAND_START "flush_ui_command_start"
#define PERF_FLUSH_UI_COMMAND_END "flush_ui_command_end"
#define PERF_CREATE_ELEMENT_START "create_element_start"
#define PERF_CREATE_ELEMENT_END "create_element_end"
#define PERF_CREATE_TEXT_NODE_START "create_text_node_start"
#define PERF_CREATE_TEXT_NODE_END "create_text_node_end"
#define PERF_CREATE_COMMENT_START "create_comment_start"
#define PERF_CREATE_COMMENT_END "create_comment_end"
#define PERF_DISPOSE_EVENT_TARGET_START "dispose_event_target_start"
#define PERF_DISPOSE_EVENT_TARGET_END "dispose_event_target_end"
#define PERF_ADD_EVENT_START "add_event_start"
#define PERF_ADD_EVENT_END "add_event_end"
#define PERF_INSERT_ADJACENT_NODE_START "insert_adjacent_node_start"
#define PERF_INSERT_ADJACENT_NODE_END "insert_adjacent_node_end"
#define PERF_REMOVE_NODE_START "remove_node_start"
#define PERF_REMOVE_NODE_END "remove_node_end"
#define PERF_SET_STYLE_START "set_style_start"
#define PERF_SET_STYLE_END "set_style_end"
#define PERF_DOM_FORCE_LAYOUT_START "dom_force_layout_start"
#define PERF_DOM_FORCE_LAYOUT_END "dom_force_layout_end"
#define PERF_DOM_FLUSH_UI_COMMAND_START "dom_flush_ui_command_start"
#define PERF_DOM_FLUSH_UI_COMMAND_END "dom_flush_ui_command_end"
#define PERF_SET_PROPERTIES_START "set_properties_start"
#define PERF_SET_PROPERTIES_END "set_properties_end"
#define PERF_REMOVE_PROPERTIES_START "remove_properties_start"
#define PERF_REMOVE_PROPERTIES_END "remove_properties_end"
#define PERF_FLEX_LAYOUT_START "flex_layout_start"
#define PERF_FLEX_LAYOUT_END "flex_layout_end"
#define PERF_FLOW_LAYOUT_START "flow_layout_start"
#define PERF_FLOW_LAYOUT_END "flow_layout_end"
#define PERF_INTRINSIC_LAYOUT_START "intrinsic_layout_start"
#define PERF_INTRINSIC_LAYOUT_END "intrinsic_layout_end"
#define PERF_SILVER_LAYOUT_START "silver_layout_start"
#define PERF_SILVER_LAYOUT_END "silver_layout_end"
#define PERF_PAINT_START "paint_start"
#define PERF_PAINT_END "paint_end"
#endif

#include "bindings/qjs/host_object.h"

namespace kraken::binding::qjs {

void bindPerformance(std::unique_ptr<ExecutionContext>& context);

struct NativePerformanceEntry {
  NativePerformanceEntry(const std::string& name, const std::string& entryType, int64_t startTime, int64_t duration, int64_t uniqueId) : startTime(startTime), duration(duration), uniqueId(uniqueId) {
    this->name = new char[name.size() + 1];
    this->entryType = new char[entryType.size() + 1];
    strcpy(this->name, name.data());
    strcpy(this->entryType, entryType.data());
  };
  char* name;
  char* entryType;
  int64_t startTime;
  int64_t duration;
  int64_t uniqueId;
};

class PerformanceEntry : public HostObject {
 public:
  PerformanceEntry() = delete;
  explicit PerformanceEntry(ExecutionContext* context, NativePerformanceEntry* m_nativePerformanceEntry);

  DEFINE_READONLY_PROPERTY(name);
  DEFINE_READONLY_PROPERTY(entryType);
  DEFINE_READONLY_PROPERTY(startTime);
  DEFINE_READONLY_PROPERTY(duration);

 private:
  NativePerformanceEntry* m_nativePerformanceEntry{nullptr};
};

class PerformanceMark : public PerformanceEntry {
 public:
  PerformanceMark() = delete;
  explicit PerformanceMark(ExecutionContext* context, std::string& name, int64_t startTime);
  explicit PerformanceMark(ExecutionContext* context, NativePerformanceEntry* nativePerformanceEntry);
};

class PerformanceMeasure : public PerformanceEntry {
 public:
  PerformanceMeasure() = delete;
  explicit PerformanceMeasure(ExecutionContext* context, std::string& name, int64_t startTime, int64_t duration);
  explicit PerformanceMeasure(ExecutionContext* context, NativePerformanceEntry* nativePerformanceEntry);
};

class NativePerformance {
 public:
  void mark(const std::string& markName);
  void mark(const std::string& markName, int64_t startTime);
  std::vector<NativePerformanceEntry*>* entries{new std::vector<NativePerformanceEntry*>()};
};

class Performance : public HostObject {
 public:
  Performance() = delete;
  explicit Performance(ExecutionContext* context);

  OBJECT_INSTANCE(Performance);

  static JSValue now(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue toJSON(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue clearMarks(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue clearMeasures(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getEntries(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getEntriesByName(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue getEntriesByType(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue mark(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue measure(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

#if ENABLE_PROFILE
  static JSValue __kraken_navigation_summary__(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  void measureSummary(JSValue* exception);
#endif

  NativePerformance m_nativePerformance;

  DEFINE_READONLY_PROPERTY(timeOrigin);

 private:
  void internalMeasure(const std::string& name, const std::string& startMark, const std::string& endMark, JSValue* exception);
  double internalNow();
  std::vector<NativePerformanceEntry*> getFullEntries();

  DEFINE_FUNCTION(now, 0);
  DEFINE_FUNCTION(toJSON, 0);
  DEFINE_FUNCTION(clearMarks, 1);
  DEFINE_FUNCTION(clearMeasures, 1);
  DEFINE_FUNCTION(getEntries, 0);
  DEFINE_FUNCTION(getEntriesByName, 2);
  DEFINE_FUNCTION(getEntriesByType, 1);
  DEFINE_FUNCTION(mark, 1);
  DEFINE_FUNCTION(measure, 4);

#if ENABLE_PROFILE
  DEFINE_FUNCTION(__kraken_navigation_summary__, 0);
#endif
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_PERFORMANCE_H
