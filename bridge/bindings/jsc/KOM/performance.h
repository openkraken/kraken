/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "bindings/jsc/host_object.h"
#include "bindings/jsc/js_context.h"
#include "bindings/jsc/macros.h"
#include <unordered_map>
#include <vector>

namespace kraken::binding::jsc {

#define JSPerformanceName "Performance"

#if ENABLE_PROFILE
#define PERF_WIDGET_CREATION_COST "widget_creation_cost"
#define PERF_CONTROLLER_PROPERTIES_INIT_COST "kraken_controller_properties_init_cost"
#define PERF_VIEW_CONTROLLER_PROPERTIES_INIT_COST "kraken_view_controller_properties_init_cost"
#define PERF_BRIDGE_INIT_COST "kraken_bridge_init_cost"
#define PERF_BRIDGE_REGISTER_DART_METHOD_COST "kraken_bridge_register_dart_method_cost"
#define PERF_CREATE_VIEWPORT_COST "kraken_create_viewport"
#define PERF_ELEMENT_MANAGER_INIT_COST "kraken_element_manager_init_cost"
#define PERF_ELEMENT_MANAGER_PROPERTIES_INIT_COST "kraken_element_manager_property_init_cost"
#define PERF_BODY_ELEMENT_INIT_COST "kraken_body_element_init_cost"
#define PERF_BODY_ELEMENT_PROPERTIES_INIT_COST "kraken_body_element_property_init_cost"
#define PERF_JS_CONTEXT_INIT_COST "js_context_init_cost"
#define PERF_JS_NATIVE_METHOD_INIT_COST "native_method_init_cost"
#define PERF_JS_POLYFILL_INIT_COST "polyfill_init_cost"

#define PERF_CONTROLLER_INIT_START "kraken_controller_init_start"
#define PERF_CONTROLLER_INIT_END "kraken_controller_init_end"
#define PERF_CONTROLLER_PROPERTY_INIT "kraken_controller_properties_init"
#define PERF_VIEW_CONTROLLER_INIT_START "kraken_view_controller_init_start"
#define PERF_VIEW_CONTROLLER_PROPERTY_INIT "kraken_view_controller_property_init"
#define PERF_BRIDGE_INIT_START "kraken_bridge_init_start"
#define PERF_BRIDGE_INIT_END "kraken_bridge_init_end"
#define PERF_BRIDGE_REGISTER_DART_METHOD_START "kraken_bridge_register_dart_method_start"
#define PERF_BRIDGE_REGISTER_DART_METHOD_END "kraken_bridge_register_dart_method_end"
#define PERF_CREATE_VIEWPORT_START "kraken_create_viewport_start"
#define PERF_CREATE_VIEWPORT_END "kraken_create_viewport_end"
#define PERF_ELEMENT_MANAGER_INIT_START "kraken_element_manager_init_start"
#define PERF_ELEMENT_MANAGER_INIT_END "kraken_element_manager_init_end"
#define PERF_ELEMENT_MANAGER_PROPERTY_INIT "kraken_element_manager_property_init"
#define PERF_BODY_ELEMENT_INIT_START "kraken_body_element_init_start"
#define PERF_BODY_ELEMENT_INIT_END "kraken_body_element_init_end"
#define PERF_BODY_ELEMENT_PROPERTY_INIT "kraken_body_element_property_init"
#define PERF_JS_CONTEXT_INIT_START "js_context_start"
#define PERF_JS_CONTEXT_INIT_END "js_context_end"
#define PERF_JS_NATIVE_METHOD_INIT_START "init_native_method_start"
#define PERF_JS_NATIVE_METHOD_INIT_END "init_native_method_end"
#define PERF_JS_POLYFILL_INIT_START "init_js_polyfill_start"
#define PERF_JS_POLYFILL_INIT_END "init_js_polyfill_end"
#endif

void bindPerformance(std::unique_ptr<JSContext> &context);

struct NativePerformanceEntry {
  NativePerformanceEntry(const std::string &name, const std::string &entryType, double startTime, double duration)
    : startTime(startTime), duration(duration) {
    this->name = new char[name.size() + 1];
    this->entryType = new char[entryType.size() + 1];
    strcpy(this->name, name.data());
    strcpy(this->entryType, entryType.data());
  };
  char *name;
  char *entryType;
  double startTime;
  double duration;
};

class JSPerformance;

class JSPerformanceEntry : public HostObject {
public:
  DEFINE_OBJECT_PROPERTY(PerformanceEntry, 4, name, entryType, startTime, duration)

  JSPerformanceEntry() = delete;
  explicit JSPerformanceEntry(JSContext *context, NativePerformanceEntry *nativePerformanceEntry);

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  friend JSPerformance;
  NativePerformanceEntry *m_nativePerformanceEntry;
};

class JSPerformanceMark : public JSPerformanceEntry {
public:
  JSPerformanceMark() = delete;
  explicit JSPerformanceMark(JSContext *context, std::string &name, double startTime);
  explicit JSPerformanceMark(JSContext *context, NativePerformanceEntry *nativePerformanceEntry);

private:
};

class JSPerformanceMeasure : public JSPerformanceEntry {
public:
  JSPerformanceMeasure() = delete;
  explicit JSPerformanceMeasure(JSContext *context, std::string &name, double startTime, double duration);
  explicit JSPerformanceMeasure(JSContext *context, NativePerformanceEntry *nativePerformanceEntry);
};

class NativePerformance {
public:
  static std::unordered_map<JSContext *, NativePerformance *> instanceMap;
  static NativePerformance *instance(JSContext *context);
  static void disposeInstance(JSContext *context);

  void mark(const std::string &markName);
  void mark(const std::string &markName, double startTime);
  std::vector<NativePerformanceEntry *> entries;
};

class JSPerformance : public HostObject {
public:
  DEFINE_OBJECT_PROPERTY(Performance, 11, now, timeOrigin, toJSON, clearMarks, clearMeasures, getEntries,
                         getEntriesByName, getEntriesByType, mark, measure, summary)

  static JSValueRef now(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                        const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef timeOrigin(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef toJSON(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef clearMarks(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef clearMeasures(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getEntries(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getEntriesByName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getEntriesByType(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef mark(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef measure(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception);

#if ENABLE_PROFILE
  static JSValueRef summary(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception);
#endif

  JSPerformance(JSContext *context, NativePerformance *nativePerformance)
    : HostObject(context, JSPerformanceName), nativePerformance(nativePerformance) {}
  ~JSPerformance() override;
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  friend JSPerformanceEntry;
  JSFunctionHolder m_now{context, "now", now};
  JSFunctionHolder m_toJSON{context, "toJSON", toJSON};
  JSFunctionHolder m_clearMarks{context, "clearMarks", clearMarks};
  JSFunctionHolder m_clearMeasures{context, "clearMeasures", clearMeasures};
  JSFunctionHolder m_getEntries{context, "getEntries", getEntries};
  JSFunctionHolder m_getEntriesByName{context, "getEntriesByName", getEntriesByName};
  JSFunctionHolder m_getEntriesByType{context, "getEntriesByType", getEntriesByType};
  JSFunctionHolder m_mark{context, "mark", mark};
  JSFunctionHolder m_measure{context, "measure", measure};

#if ENABLE_PROFILE
  JSFunctionHolder m_summary{context, "summary", summary};
  void measureSummary(JSValueRef *exception);
#endif
  void internalMeasure(const std::string &name, const std::string &startMark, const std::string &endMark,
                       JSValueRef *exception);
  double internalNow();
  std::vector<NativePerformanceEntry*> getFullEntries();
  NativePerformance *nativePerformance{nullptr};
};

} // namespace kraken::binding::jsc
