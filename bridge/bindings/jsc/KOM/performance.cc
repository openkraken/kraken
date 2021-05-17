/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "performance.h"
#include "dart_methods.h"
#include "foundation/logging.h"
#include <chrono>
#include <cmath>

#define PERFORMANCE_ENTRY_NONE_UNIQUE_ID -1024

namespace kraken::binding::jsc {

using namespace std::chrono;

std::unordered_map<int32_t, NativePerformance *> NativePerformance::instanceMap{};
NativePerformance *NativePerformance::instance(int32_t uniqueId) {
  if (instanceMap.count(uniqueId) == 0) {
    instanceMap[uniqueId] = new NativePerformance();
  }

  return instanceMap[uniqueId];
}

void NativePerformance::disposeInstance(int32_t uniqueId) {
  if (instanceMap.count(uniqueId) > 0) delete instanceMap[uniqueId];
}

void NativePerformance::mark(const std::string &markName) {
  int64_t startTime = std::chrono::duration_cast<microseconds>(system_clock::now().time_since_epoch()).count();
  auto *nativePerformanceEntry =
    new NativePerformanceEntry{markName, "mark", startTime, 0, PERFORMANCE_ENTRY_NONE_UNIQUE_ID};
  entries.emplace_back(nativePerformanceEntry);
}

void NativePerformance::mark(const std::string &markName, int64_t startTime) {
  auto *nativePerformanceEntry =
    new NativePerformanceEntry{markName, "mark", startTime, 0, PERFORMANCE_ENTRY_NONE_UNIQUE_ID};
  entries.emplace_back(nativePerformanceEntry);
}

JSObjectRef buildPerformanceEntry(const std::string &entryType, JSContext *context,
                                  NativePerformanceEntry *nativePerformanceEntry) {
  if (entryType == "mark") {
    auto *mark = new JSPerformanceMark(context, nativePerformanceEntry);
    return mark->jsObject;
  } else if (entryType == "measure") {
    auto *measure = new JSPerformanceMeasure(context, nativePerformanceEntry);
    return measure->jsObject;
  }

  return nullptr;
}

JSPerformanceEntry::JSPerformanceEntry(JSContext *context, NativePerformanceEntry *nativePerformanceEntry)
  : HostObject(context, "PerformanceEntry"), m_nativePerformanceEntry(nativePerformanceEntry) {}

JSValueRef JSPerformanceEntry::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPerformanceEntryPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case PerformanceEntryProperty::name: {
      JSStringRef nameValue = JSStringCreateWithUTF8CString(m_nativePerformanceEntry->name);
      return JSValueMakeString(ctx, nameValue);
    }
    case PerformanceEntryProperty::entryType: {
      JSStringRef entryValue = JSStringCreateWithUTF8CString(m_nativePerformanceEntry->entryType);
      return JSValueMakeString(ctx, entryValue);
    }
    case PerformanceEntryProperty::startTime:
      return JSValueMakeNumber(ctx, m_nativePerformanceEntry->startTime);
    case PerformanceEntryProperty::duration:
      return JSValueMakeNumber(ctx, m_nativePerformanceEntry->duration);
    }
  }
  return nullptr;
}

JSPerformanceMark::JSPerformanceMark(JSContext *context, std::string &name, int64_t startTime)
  : JSPerformanceEntry(context,
                       new NativePerformanceEntry(name, "mark", startTime, 0, PERFORMANCE_ENTRY_NONE_UNIQUE_ID)) {}
JSPerformanceMark::JSPerformanceMark(JSContext *context, NativePerformanceEntry *nativePerformanceEntry)
  : JSPerformanceEntry(context, nativePerformanceEntry) {}

JSPerformanceMeasure::JSPerformanceMeasure(JSContext *context, std::string &name, int64_t startTime, int64_t duration)
  : JSPerformanceEntry(
      context, new NativePerformanceEntry(name, "measure", startTime, duration, PERFORMANCE_ENTRY_NONE_UNIQUE_ID)) {}
JSPerformanceMeasure::JSPerformanceMeasure(JSContext *context, NativePerformanceEntry *nativePerformanceEntry)
  : JSPerformanceEntry(context, nativePerformanceEntry) {}

JSValueRef JSPerformance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPerformancePropertyMap();
  auto prototypePropertyMap = getPerformancePrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) return nullptr;

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case PerformanceProperty::timeOrigin: {
      double time =
        std::chrono::duration_cast<std::chrono::milliseconds>(context->timeOrigin.time_since_epoch()).count();
      return JSValueMakeNumber(ctx, time);
    }
    default:
      break;
    }
  }

  return HostObject::getProperty(name, exception);
}

void JSPerformanceEntry::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getPerformanceEntryPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSPerformance::~JSPerformance() {}

void JSPerformance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getPerformancePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }

  for (auto &property : getPerformancePrototypePropertyNames()) {
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
  auto instance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  double now = instance->internalNow();
  return JSValueMakeNumber(ctx, now);
}

JSValueRef JSPerformance::timeOrigin(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, JSValueRef const *arguments, JSValueRef *exception) {
  auto instance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  double time =
    std::chrono::duration_cast<std::chrono::milliseconds>(instance->context->timeOrigin.time_since_epoch()).count();
  return JSValueMakeNumber(ctx, time);
}

JSValueRef JSPerformance::toJSON(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef *arguments, JSValueRef *exception) {
  auto instance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  double now = instance->internalNow();
  double timeOrigin =
    std::chrono::duration_cast<std::chrono::milliseconds>(instance->context->timeOrigin.time_since_epoch()).count();

  auto context = instance->context;
  auto object = JSObjectMake(ctx, nullptr, exception);
  JSC_SET_STRING_PROPERTY(context, object, "now", JSValueMakeNumber(ctx, now));
  JSC_SET_STRING_PROPERTY(context, object, "timeOrigin", JSValueMakeNumber(ctx, timeOrigin));
  return object;
}

JSValueRef JSPerformance::clearMarks(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  JSValueRef targetMark = nullptr;
  if (argumentCount == 1) {
    targetMark = arguments[0];
  }

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  auto &entries = performance->nativePerformance->entries;
  auto it = std::begin(entries);

  while (it != entries.end()) {
    std::string entryType = (*it)->entryType;
    if (entryType == "mark") {
      if (targetMark == nullptr) {
        entries.erase(it);
      } else {
        std::string entryName = (*it)->name;
        std::string targetName = JSStringToStdString(JSValueToStringCopy(ctx, targetMark, exception));
        if (entryName == targetName) {
          entries.erase(it);
        } else {
          it++;
        };
      }
    } else {
      it++;
    }
  }

  return nullptr;
}

JSValueRef JSPerformance::clearMeasures(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  JSValueRef targetMark = nullptr;
  if (argumentCount == 1) {
    targetMark = arguments[0];
  }

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  auto &entries = performance->nativePerformance->entries;
  auto it = std::begin(entries);

  while (it != entries.end()) {
    std::string entryType = (*it)->entryType;
    if (entryType == "measure") {
      if (targetMark == nullptr) {
        entries.erase(it);
      } else {
        std::string entryName = (*it)->name;
        std::string targetName = JSStringToStdString(JSValueToStringCopy(ctx, targetMark, exception));
        if (entryName == targetName) {
          entries.erase(it);
        } else {
          it++;
        }
      }
    } else {
      it++;
    }
  }

  return nullptr;
}

JSValueRef JSPerformance::getEntries(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  auto entries = performance->getFullEntries();

  size_t entriesSize = entries.size();
  JSValueRef args[entriesSize];

  for (size_t i = 0; i < entriesSize; i++) {
    auto &entry = entries[i];
    auto entryType = std::string(entry->entryType);
    args[i] = buildPerformanceEntry(entryType, performance->context, entry);
  }

  JSObjectRef entriesArray = JSObjectMakeArray(ctx, entriesSize, args, exception);
  return entriesArray;
}

JSValueRef JSPerformance::getEntriesByName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    throwJSError(ctx, "Failed to execute 'getEntriesByName' on 'Performance': 1 argument required, but only 0 present.",
                 exception);
    return nullptr;
  }

  JSStringRef targetNameStrRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string targetName = JSStringToStdString(targetNameStrRef);

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  std::vector<JSObjectRef> targetEntries;
  auto entries = performance->getFullEntries();

  for (auto &m_entries : entries) {
    if (m_entries->name == targetName) {
      std::string entryType = std::string(m_entries->entryType);
      auto performanceEntry = buildPerformanceEntry(entryType, performance->context, m_entries);
      targetEntries.emplace_back(performanceEntry);
    }
  }

  return JSObjectMakeArray(ctx, targetEntries.size(), targetEntries.data(), exception);
}

JSValueRef JSPerformance::getEntriesByType(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    throwJSError(ctx, "Failed to execute 'getEntriesByName' on 'Performance': 1 argument required, but only 0 present.",
                 exception);
    return nullptr;
  }

  JSStringRef entryTypeStrRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string entryType = JSStringToStdString(entryTypeStrRef);

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  std::vector<JSObjectRef> targetEntries;
  auto entries = performance->getFullEntries();

  for (auto &m_entries : entries) {
    if (m_entries->entryType == entryType) {
      auto performanceEntry = buildPerformanceEntry(entryType, performance->context, m_entries);
      targetEntries.emplace_back(performanceEntry);
    }
  }

  return JSObjectMakeArray(ctx, targetEntries.size(), targetEntries.data(), exception);
}

JSValueRef JSPerformance::mark(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to execute 'mark' on 'Performance': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  JSStringRef markNameRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string markName = JSStringToStdString(markNameRef);

  performance->nativePerformance->mark(markName);

  return nullptr;
}

#if ENABLE_PROFILE

std::vector<NativePerformanceEntry *> findAllMeasures(const std::vector<NativePerformanceEntry *> &entries,
                                                      const std::string &targetName) {
  std::vector<NativePerformanceEntry *> resultEntries;

  for (auto entry : entries) {
    if (entry->name == targetName) {
      resultEntries.emplace_back(entry);
    }
  }

  return resultEntries;
};

double getMeasureTotalDuration(const std::vector<NativePerformanceEntry *> &measures) {
  double duration = 0.0;
  for (auto entry : measures) {
    duration += entry->duration;
  }
  return duration / 1000;
}

JSValueRef JSPerformance::__kraken_navigation_summary__(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                        size_t argumentCount, JSValueRef const *arguments,
                                                        JSValueRef *exception) {
  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  performance->measureSummary();

  std::vector<NativePerformanceEntry *> entries = performance->getFullEntries();
  std::vector<NativePerformanceEntry *> measures;
  for (auto &m_entries : entries) {
    if (std::string(m_entries->entryType) == "measure") {
      measures.emplace_back(m_entries);
    }
  }

#define GET_COST_WITH_DECREASE(NAME, MACRO, DECREASE)                                                                  \
  auto NAME##Measures = findAllMeasures(measures, MACRO);                                                              \
  size_t NAME##Count = NAME##Measures.size();                                                                          \
  double NAME##Cost = getMeasureTotalDuration(NAME##Measures) - (DECREASE);                                            \
  auto NAME##Avg = NAME##Measures.empty() ? 0 : (NAME##Cost) / NAME##Measures.size();

#define GET_COST(NAME, MACRO)                                                                                          \
  auto NAME##Measures = findAllMeasures(measures, MACRO);                                                              \
  size_t NAME##Count = NAME##Measures.size();                                                                          \
  double NAME##Cost = getMeasureTotalDuration(NAME##Measures);                                                         \
  auto NAME##Avg = NAME##Measures.empty() ? 0 : NAME##Cost / NAME##Measures.size();

  GET_COST(widgetCreation, PERF_WIDGET_CREATION_COST);
  GET_COST(controllerPropertiesInit, PERF_CONTROLLER_PROPERTIES_INIT_COST);
  GET_COST(viewControllerPropertiesInit, PERF_VIEW_CONTROLLER_PROPERTIES_INIT_COST);
  GET_COST(bridgeInit, PERF_BRIDGE_INIT_COST);
  GET_COST(bridgeRegisterDartMethod, PERF_BRIDGE_REGISTER_DART_METHOD_COST);
  GET_COST(createViewport, PERF_CREATE_VIEWPORT_COST);
  GET_COST(elementManagerInit, PERF_ELEMENT_MANAGER_INIT_COST);
  GET_COST(elementManagerPropertiesInit, PERF_ELEMENT_MANAGER_PROPERTIES_INIT_COST);
  GET_COST(rootElementInit, PERF_ROOT_ELEMENT_INIT_COST);
  GET_COST(rootElementPropertiesInit, PERF_ROOT_ELEMENT_PROPERTIES_INIT_COST);
  GET_COST(jsContextInit, PERF_JS_CONTEXT_INIT_COST);
  GET_COST(jsNativeMethodInit, PERF_JS_NATIVE_METHOD_INIT_COST);
  GET_COST(jsPolyfillInit, PERF_JS_POLYFILL_INIT_COST);
  GET_COST(jsBundleLoad, PERF_JS_BUNDLE_LOAD_COST);
  GET_COST(jsParseTime, PERF_JS_PARSE_TIME_COST);
  GET_COST(flushUiCommand, PERF_FLUSH_UI_COMMAND_COST);
  GET_COST(createElement, PERF_CREATE_ELEMENT_COST);
  GET_COST(createTextNode, PERF_CREATE_TEXT_NODE_COST);
  GET_COST(createComment, PERF_CREATE_COMMENT_COST);
  GET_COST(disposeEventTarget, PERF_DISPOSE_EVENT_TARGET_COST);
  GET_COST(addEvent, PERF_ADD_EVENT_COST);
  GET_COST(insertAdjacentNode, PERF_INSERT_ADJACENT_NODE_COST);
  GET_COST(removeNode, PERF_REMOVE_NODE_COST);
  GET_COST(setStyle, PERF_SET_STYLE_COST);
  GET_COST(setProperties, PERF_SET_PROPERTIES_COST);
  GET_COST(removeProperties, PERF_REMOVE_PROPERTIES_COST);
  GET_COST(flexLayout, PERF_FLEX_LAYOUT_COST);
  GET_COST(flowLayout, PERF_FLOW_LAYOUT_COST);
  GET_COST(intrinsicLayout, PERF_INTRINSIC_LAYOUT_COST);
  GET_COST(silverLayout, PERF_SILVER_LAYOUT_COST);
  GET_COST(paint, PERF_PAINT_COST);
  GET_COST(domForceLayout, PERF_DOM_FORCE_LAYOUT_COST);
  GET_COST(domFlushUICommand, PERF_DOM_FLUSH_UI_COMMAND_COST);
  GET_COST_WITH_DECREASE(jsHostClassGetProperty, PERF_JS_HOST_CLASS_GET_PROPERTY_COST,
                         domForceLayoutCost + domFlushUICommandCost)
  GET_COST(jsHostClassSetProperty, PERF_JS_HOST_CLASS_SET_PROPERTY_COST);
  GET_COST_WITH_DECREASE(jsBundleEval, PERF_JS_BUNDLE_EVAL_COST, domForceLayoutCost + domFlushUICommandCost);

  double initBundleCost = jsBundleLoadCost + jsBundleEvalCost + flushUiCommandCost + createElementCost +
                          createTextNodeCost + createCommentCost + disposeEventTargetCost + addEventCost +
                          insertAdjacentNodeCost + removeNodeCost + setStyleCost + setPropertiesCost +
                          removePropertiesCost;
  // layout and paint measure are not correct.
  //  double renderingCost = flexLayoutCost + flowLayoutCost + intrinsicLayoutCost + silverLayoutCost + paintCost;
  double totalCost = widgetCreationCost + initBundleCost;

  char buffer[5000];
  // clang-format off
  sprintf(buffer, R"(
Total time cost(without paint and layout): %.*fms

+ %s %.*fms
  + %s %.*fms
  + %s %.*fms
  + %s %.*fms
  + %s %.*fms
  + %s %.*fms
  + %s %.*fms
  + %s %.*fms
  + %s %.*fms
    + %s %.*fms
    + %s %.*fms
    + %s %.*fms
    + %s %.*fms
First Bundle Load: %.*fms
  + %s %.*fms
  + %s %.*fms
  + %s %.*fms
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
)",
  2, totalCost,
    PERF_WIDGET_CREATION_COST, 2, widgetCreationCost,
      PERF_CONTROLLER_PROPERTIES_INIT_COST, 2, controllerPropertiesInitCost,
      PERF_VIEW_CONTROLLER_PROPERTIES_INIT_COST, 2, viewControllerPropertiesInitCost,
      PERF_ELEMENT_MANAGER_INIT_COST, 2, elementManagerInitCost,
      PERF_ELEMENT_MANAGER_PROPERTY_INIT, 2, elementManagerPropertiesInitCost,
      PERF_ROOT_ELEMENT_PROPERTIES_INIT_COST, 2, rootElementPropertiesInitCost,
      PERF_ROOT_ELEMENT_INIT_COST, 2, rootElementInitCost,
      PERF_CREATE_VIEWPORT_COST, 2, createViewportCost,
      PERF_BRIDGE_INIT_COST, 2, bridgeInitCost,
      PERF_BRIDGE_REGISTER_DART_METHOD_COST, 2, bridgeRegisterDartMethodCost,
      PERF_JS_CONTEXT_INIT_COST, 2, jsContextInitCost,
      PERF_JS_NATIVE_METHOD_INIT_COST, 2, jsNativeMethodInitCost,
      PERF_JS_POLYFILL_INIT_COST, 2, jsPolyfillInitCost,
  2, initBundleCost,
    PERF_JS_BUNDLE_LOAD_COST, 2, jsBundleLoadCost,
    PERF_JS_BUNDLE_EVAL_COST, 2, jsBundleEvalCost,
    PERF_JS_PARSE_TIME_COST, 2, jsParseTimeCost,
    PERF_FLUSH_UI_COMMAND_COST, 2, flushUiCommandCost, 2, flushUiCommandAvg, flushUiCommandCount,
    PERF_CREATE_ELEMENT_COST, 2, createElementCost, 2, createElementAvg, createElementCount,
    PERF_JS_HOST_CLASS_GET_PROPERTY_COST, 2, jsHostClassGetPropertyCost, 2, jsHostClassGetPropertyAvg, jsHostClassGetPropertyCount,
    PERF_JS_HOST_CLASS_SET_PROPERTY_COST, 2, jsHostClassSetPropertyCost, 2, jsHostClassSetPropertyAvg, jsHostClassSetPropertyCount,
    PERF_CREATE_TEXT_NODE_COST, 2, createTextNodeCost, 2, createTextNodeAvg, createTextNodeCount,
    PERF_CREATE_COMMENT_COST, 2, createCommentCost, 2, createCommentAvg, createCommentCount,
    PERF_DISPOSE_EVENT_TARGET_COST, 2, disposeEventTargetCost, 2, disposeEventTargetAvg, disposeEventTargetCount,
    PERF_ADD_EVENT_COST, 2, addEventCost, 2, addEventAvg, addEventCount,
    PERF_INSERT_ADJACENT_NODE_COST, 2, insertAdjacentNodeCost, 2, insertAdjacentNodeAvg, insertAdjacentNodeCount,
    PERF_REMOVE_NODE_COST, 2, removeNodeCost, 2, removeNodeAvg, removeNodeCount,
    PERF_SET_STYLE_COST, 2, setStyleCost, 2, setStyleAvg, setStyleCount,
    PERF_DOM_FORCE_LAYOUT_COST, 2, domForceLayoutCost, 2, domForceLayoutAvg, domForceLayoutCount,
    PERF_DOM_FLUSH_UI_COMMAND_COST, 2, domFlushUICommandCost, 2, domFlushUICommandAvg, domFlushUICommandCount,
    PERF_SET_PROPERTIES_COST, 2, setPropertiesCost, 2, setPropertiesAvg, setPropertiesCount,
    PERF_REMOVE_PROPERTIES_COST, 2, removePropertiesCost, 2, removePropertiesAvg, removePropertiesCount
);
  // clang-format on

  JSStringRef resultStringRef = JSStringCreateWithUTF8CString(buffer);
  return JSValueMakeString(ctx, resultStringRef);
}

void JSPerformance::measureSummary() {
  internalMeasure(PERF_WIDGET_CREATION_COST, PERF_CONTROLLER_INIT_START, PERF_CONTROLLER_INIT_END, nullptr);
  internalMeasure(PERF_CONTROLLER_PROPERTIES_INIT_COST, PERF_CONTROLLER_INIT_START, PERF_CONTROLLER_PROPERTY_INIT,
                  nullptr);
  internalMeasure(PERF_VIEW_CONTROLLER_PROPERTIES_INIT_COST, PERF_VIEW_CONTROLLER_INIT_START,
                  PERF_VIEW_CONTROLLER_PROPERTY_INIT, nullptr);
  internalMeasure(PERF_BRIDGE_INIT_COST, PERF_BRIDGE_INIT_START, PERF_BRIDGE_INIT_END, nullptr);
  internalMeasure(PERF_BRIDGE_REGISTER_DART_METHOD_COST, PERF_BRIDGE_REGISTER_DART_METHOD_START,
                  PERF_BRIDGE_REGISTER_DART_METHOD_END, nullptr);
  internalMeasure(PERF_CREATE_VIEWPORT_COST, PERF_CREATE_VIEWPORT_START, PERF_CREATE_VIEWPORT_END, nullptr);
  internalMeasure(PERF_ELEMENT_MANAGER_INIT_COST, PERF_ELEMENT_MANAGER_INIT_START, PERF_ELEMENT_MANAGER_INIT_END,
                  nullptr);
  internalMeasure(PERF_ELEMENT_MANAGER_PROPERTIES_INIT_COST, PERF_ELEMENT_MANAGER_INIT_START,
                  PERF_ELEMENT_MANAGER_PROPERTY_INIT, nullptr);
  internalMeasure(PERF_ROOT_ELEMENT_INIT_COST, PERF_ROOT_ELEMENT_INIT_START, PERF_ROOT_ELEMENT_INIT_END, nullptr);
  internalMeasure(PERF_ROOT_ELEMENT_PROPERTIES_INIT_COST, PERF_ROOT_ELEMENT_INIT_START, PERF_ROOT_ELEMENT_PROPERTY_INIT,
                  nullptr);
  internalMeasure(PERF_JS_CONTEXT_INIT_COST, PERF_JS_CONTEXT_INIT_START, PERF_JS_CONTEXT_INIT_END, nullptr);
  internalMeasure(PERF_JS_HOST_CLASS_GET_PROPERTY_COST, PERF_JS_HOST_CLASS_GET_PROPERTY_START,
                  PERF_JS_HOST_CLASS_GET_PROPERTY_END, nullptr);
  internalMeasure(PERF_JS_HOST_CLASS_SET_PROPERTY_COST, PERF_JS_HOST_CLASS_SET_PROPERTY_START,
                  PERF_JS_HOST_CLASS_SET_PROPERTY_END, nullptr);
  internalMeasure(PERF_JS_NATIVE_METHOD_INIT_COST, PERF_JS_NATIVE_METHOD_INIT_START, PERF_JS_NATIVE_METHOD_INIT_END,
                  nullptr);
  internalMeasure(PERF_JS_POLYFILL_INIT_COST, PERF_JS_POLYFILL_INIT_START, PERF_JS_POLYFILL_INIT_END, nullptr);
  internalMeasure(PERF_JS_BUNDLE_LOAD_COST, PERF_JS_BUNDLE_LOAD_START, PERF_JS_BUNDLE_LOAD_END, nullptr);
  internalMeasure(PERF_JS_BUNDLE_EVAL_COST, PERF_JS_BUNDLE_EVAL_START, PERF_JS_BUNDLE_EVAL_END, nullptr);
  internalMeasure(PERF_FLUSH_UI_COMMAND_COST, PERF_FLUSH_UI_COMMAND_START, PERF_FLUSH_UI_COMMAND_END, nullptr);
  internalMeasure(PERF_CREATE_ELEMENT_COST, PERF_CREATE_ELEMENT_START, PERF_CREATE_ELEMENT_END, nullptr);
  internalMeasure(PERF_CREATE_TEXT_NODE_COST, PERF_CREATE_TEXT_NODE_START, PERF_CREATE_TEXT_NODE_END, nullptr);
  internalMeasure(PERF_CREATE_COMMENT_COST, PERF_CREATE_COMMENT_START, PERF_CREATE_COMMENT_END, nullptr);
  internalMeasure(PERF_DISPOSE_EVENT_TARGET_COST, PERF_DISPOSE_EVENT_TARGET_START, PERF_DISPOSE_EVENT_TARGET_END,
                  nullptr);
  internalMeasure(PERF_ADD_EVENT_COST, PERF_ADD_EVENT_START, PERF_ADD_EVENT_END, nullptr);
  internalMeasure(PERF_INSERT_ADJACENT_NODE_COST, PERF_INSERT_ADJACENT_NODE_START, PERF_INSERT_ADJACENT_NODE_END,
                  nullptr);
  internalMeasure(PERF_REMOVE_NODE_COST, PERF_REMOVE_NODE_START, PERF_REMOVE_NODE_END, nullptr);
  internalMeasure(PERF_SET_STYLE_COST, PERF_SET_STYLE_START, PERF_SET_STYLE_END, nullptr);
  internalMeasure(PERF_SET_PROPERTIES_COST, PERF_SET_PROPERTIES_START, PERF_SET_PROPERTIES_END, nullptr);
  internalMeasure(PERF_REMOVE_PROPERTIES_COST, PERF_REMOVE_PROPERTIES_START, PERF_REMOVE_PROPERTIES_END, nullptr);
  internalMeasure(PERF_FLEX_LAYOUT_COST, PERF_FLEX_LAYOUT_START, PERF_FLEX_LAYOUT_END, nullptr);
  internalMeasure(PERF_FLOW_LAYOUT_COST, PERF_FLOW_LAYOUT_START, PERF_FLOW_LAYOUT_END, nullptr);
  internalMeasure(PERF_INTRINSIC_LAYOUT_COST, PERF_INTRINSIC_LAYOUT_START, PERF_INTRINSIC_LAYOUT_END, nullptr);
  internalMeasure(PERF_SILVER_LAYOUT_COST, PERF_SILVER_LAYOUT_START, PERF_SILVER_LAYOUT_END, nullptr);
  internalMeasure(PERF_PAINT_COST, PERF_PAINT_START, PERF_PAINT_END, nullptr);
  internalMeasure(PERF_DOM_FORCE_LAYOUT_COST, PERF_DOM_FORCE_LAYOUT_START, PERF_DOM_FORCE_LAYOUT_END, nullptr);
  internalMeasure(PERF_DOM_FLUSH_UI_COMMAND_COST, PERF_DOM_FLUSH_UI_COMMAND_START, PERF_DOM_FLUSH_UI_COMMAND_END,
                  nullptr);
  internalMeasure(PERF_JS_PARSE_TIME_COST, PERF_JS_PARSE_TIME_START, PERF_JS_PARSE_TIME_END, nullptr);
}

#endif

JSValueRef JSPerformance::measure(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    throwJSError(ctx, "Failed to execute 'measure' on 'Performance': 1 argument required, but only 0 present.",
                 exception);
    return nullptr;
  }

  JSStringRef nameStrRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string name = JSStringToStdString(nameStrRef);
  std::string startMark;
  std::string endMark;

  if (argumentCount > 1) {
    bool isStartMarkUndefined = JSValueIsUndefined(ctx, arguments[1]);
    if (!isStartMarkUndefined) {
      JSStringRef startMarkStringRef = JSValueToStringCopy(ctx, arguments[1], exception);
      startMark = JSStringToStdString(startMarkStringRef);
    }
  }

  if (argumentCount > 2) {
    JSStringRef endMarkStringRef = JSValueToStringCopy(ctx, arguments[2], exception);
    endMark = JSStringToStdString(endMarkStringRef);
  }

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  performance->internalMeasure(name, startMark, endMark, exception);

  return nullptr;
}

std::vector<NativePerformanceEntry *> JSPerformance::getFullEntries() {
  auto &bridgeEntries = nativePerformance->entries;
#if ENABLE_PROFILE
  if (getDartMethod()->getPerformanceEntries == nullptr) {
    return std::vector<NativePerformanceEntry *>();
  }
  auto dartEntryList = getDartMethod()->getPerformanceEntries(context->getContextId());
  auto dartEntityBytes = dartEntryList->entries;
  std::vector<NativePerformanceEntry *> dartEntries;
  dartEntries.reserve(dartEntryList->length);

  for (size_t i = 0; i < dartEntryList->length * 3; i += 3) {
    const char *name = reinterpret_cast<const char *>(dartEntityBytes[i]);
    int64_t startTime = dartEntityBytes[i + 1];
    int64_t uniqueId = dartEntityBytes[i + 2];
    NativePerformanceEntry *nativePerformanceEntry = new NativePerformanceEntry(name, "mark", startTime, 0, uniqueId);
    dartEntries.emplace_back(nativePerformanceEntry);
  }
#endif

  std::vector<NativePerformanceEntry *> mergedEntries;

  mergedEntries.insert(mergedEntries.end(), bridgeEntries.begin(), bridgeEntries.end());
#if ENABLE_PROFILE
  mergedEntries.insert(mergedEntries.end(), dartEntries.begin(), dartEntries.end());
  delete[] dartEntryList->entries;
  delete dartEntryList;
#endif

  return mergedEntries;
}

void JSPerformance::internalMeasure(const std::string &name, const std::string &startMark, const std::string &endMark,
                                    JSValueRef *exception) {
  auto entries = getFullEntries();

  if (!startMark.empty() && !endMark.empty()) {
    size_t startMarkCount =
      std::count_if(entries.begin(), entries.end(),
                    [&startMark](NativePerformanceEntry *entry) -> bool { return entry->name == startMark; });

    if (startMarkCount == 0) {
      if (exception != nullptr) {
        throwJSError(
          ctx, ("Failed to execute 'measure' on 'Performance': The mark " + startMark + " does not exist.").c_str(),
          exception);
      }
      return;
    }

    size_t endMarkCount =
      std::count_if(entries.begin(), entries.end(),
                    [&endMark](NativePerformanceEntry *entry) -> bool { return entry->name == endMark; });

    if (endMarkCount == 0) {
      if (exception != nullptr) {
        throwJSError(ctx,
                     ("Failed to execute 'measure' on 'Performance': The mark " + endMark + " does not exist.").c_str(),
                     exception);
      }
      return;
    }

    if (startMarkCount != endMarkCount) {
      if (exception != nullptr) {
        throwJSError(ctx,
                     ("Failed to execute 'measure' on 'Performance': The mark " + startMark + " and " + endMark +
                      "does not appear the same number of times")
                       .c_str(),
                     exception);
      }
      return;
    }

    auto startIt = std::begin(entries);
    auto endIt = std::begin(entries);

    for (size_t i = 0; i < startMarkCount; i++) {
      auto startEntry = std::find_if(startIt, entries.end(), [&startMark](NativePerformanceEntry *entry) -> bool {
        return entry->name == startMark;
      });

      bool isStartEntryHasUniqueId = (*startEntry)->uniqueId != PERFORMANCE_ENTRY_NONE_UNIQUE_ID;

      auto endEntryComparator = [&endMark, &startEntry,
                                 isStartEntryHasUniqueId](NativePerformanceEntry *entry) -> bool {
        if (isStartEntryHasUniqueId) {
          return entry->uniqueId == (*startEntry)->uniqueId && entry->name == endMark;
        }
        return entry->name == endMark;
      };

      auto endEntry = std::find_if(startEntry, entries.end(), endEntryComparator);

      if (endEntry == entries.end()) {
        size_t startIndex = startEntry - entries.begin();
        assert_m(false, ("Can not get endEntry. startIndex: " + std::to_string(startIndex) +
                         " startMark: " + startMark + " endMark: " + endMark));
      }

      int64_t duration = (*endEntry)->startTime - (*startEntry)->startTime;
      int64_t startTime = std::chrono::duration_cast<microseconds>(system_clock::now().time_since_epoch()).count();
      auto *nativePerformanceEntry =
        new NativePerformanceEntry{name, "measure", startTime, duration, PERFORMANCE_ENTRY_NONE_UNIQUE_ID};
      nativePerformance->entries.emplace_back(nativePerformanceEntry);
      startIt = ++startEntry;
      endIt = ++endEntry;
    }
  }
}

void bindPerformance(std::unique_ptr<JSContext> &context) {
  auto performance = new JSPerformance(context.get(), NativePerformance::instance(context->uniqueId));
  JSC_GLOBAL_BINDING_HOST_OBJECT(context, "performance", performance);
}
} // namespace kraken::binding::jsc
