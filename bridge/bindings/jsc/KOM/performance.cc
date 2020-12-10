/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "performance.h"
#include <chrono>
#include <cmath>

namespace kraken::binding::jsc {

using namespace std::chrono;

JSValueRef JSPerformance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPerformancePropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case PerformanceProperty::kNow: {
      return m_now.function();
    }
    case PerformanceProperty::kTimeOrigin: {
      double time =
          std::chrono::duration_cast<std::chrono::milliseconds>(context->timeOrigin.time_since_epoch()).count();
      return JSValueMakeNumber(ctx, time);
    }
    case PerformanceProperty::ktoJSON: {
      return m_toJSON.function();
    }
    }
  }

  return HostObject::getProperty(name, exception);
}

JSPerformance::~JSPerformance() {}

std::unordered_map<std::string, JSPerformance::PerformanceProperty> &JSPerformance::getPerformancePropertyMap() {
  static std::unordered_map<std::string, PerformanceProperty> propertyMap{
    {"now", PerformanceProperty::kNow},
    {"timeOrigin", PerformanceProperty::kTimeOrigin},
    {"toJSON", PerformanceProperty::ktoJSON}};
  return propertyMap;
}

std::vector<JSStringRef> &JSPerformance::getPerformancePropertyNames() {
  static std::vector<JSStringRef> propertyNames{JSStringCreateWithUTF8CString("now"),
                                                JSStringCreateWithUTF8CString("timeOrigin"),
                                                JSStringCreateWithUTF8CString("toJSON")};
  return propertyNames;
}

void JSPerformance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getPerformancePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

double JSPerformance::internalNow() {
  auto now = std::chrono::system_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::microseconds>(now - context->timeOrigin);
  auto reducedDuration = std::floor(duration / 1000us) * 1000us;
  return std::chrono::duration_cast<std::chrono::milliseconds>(reducedDuration).count();
}

JSValueRef JSPerformance::now(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(function));
  double now = instance->internalNow();
  return JSValueMakeNumber(ctx, now);
}

JSValueRef JSPerformance::timeOrigin(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, JSValueRef const *arguments, JSValueRef *exception) {
  auto instance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(function));
  double time =
    std::chrono::duration_cast<std::chrono::milliseconds>(instance->context->timeOrigin.time_since_epoch()).count();
  return JSValueMakeNumber(ctx, time);
}

JSValueRef JSPerformance::toJSON(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(function));
  double now = instance->internalNow();
  double timeOrigin =
    std::chrono::duration_cast<std::chrono::milliseconds>(instance->context->timeOrigin.time_since_epoch()).count();

  auto context = instance->context;
  auto object = JSObjectMake(ctx, nullptr, exception);
  JSC_SET_STRING_PROPERTY(context, object, "now", JSValueMakeNumber(ctx, now));
  JSC_SET_STRING_PROPERTY(context, object, "timeOrigin", JSValueMakeNumber(ctx, timeOrigin));
  return object;
}

void bindPerformance(std::unique_ptr<JSContext> &context) {
  auto performance = new JSPerformance(context.get());
  JSC_GLOBAL_BINDING_HOST_OBJECT(context, "performance", performance);
}
} // namespace kraken::binding::jsc
