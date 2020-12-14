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

void bindPerformance(std::unique_ptr<JSContext> &context);

class JSPerformance;

class JSPerformanceEntry : public HostObject {
public:
  enum class PerformanceEntryProperty { kName, kEntryType, kStartTime, kDuration};

  static std::unordered_map<std::string, PerformanceEntryProperty> &getPerformanceEntryPropertyMap();
  static std::vector<JSStringRef> &getPerformanceEntryPropertyNames();

  JSPerformanceEntry() = delete;
  explicit JSPerformanceEntry(JSContext *context, JSStringRef name, JSStringRef entryType, double startTime, double duration);

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  friend JSPerformance;
  JSStringHolder m_name{context, ""};
  JSStringHolder m_entryType{context, ""};
  double m_startTime;
  double m_duration;
};

class JSPerformanceMark : public JSPerformanceEntry {
public:
  JSPerformanceMark() = delete;
  explicit JSPerformanceMark(JSContext *context, JSStringRef name, double startTime);
private:
};

class JSPerformanceMeasure : public JSPerformanceEntry {
public:
  JSPerformanceMeasure() = delete;
  explicit JSPerformanceMeasure(JSContext *context, JSStringRef name, double startTime, double duration);
};

class JSPerformance : public HostObject {
public:
  DEFINE_OBJECT_PROPERTY(Performance, 3, now, timeOrigin, toJSON)

  static JSValueRef now(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef timeOrigin(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef toJSON(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                               size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef clearMarks(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                           size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef clearMeasures(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                  size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getEntries(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                               size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getEntriesByName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getEntriesByType(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef mark(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                         size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef measure(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                            size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  JSPerformance(JSContext *context) : HostObject(context, JSPerformanceName) {}

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
  double internalNow();

  std::vector<JSPerformanceEntry*> m_entries;
};

} // namespace kraken::binding::jsc
