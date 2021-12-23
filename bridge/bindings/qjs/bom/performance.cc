/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "performance.h"
#include <chrono>
#include "dart_methods.h"

#define PERFORMANCE_ENTRY_NONE_UNIQUE_ID -1024

namespace kraken::binding::qjs {

void bindPerformance(std::unique_ptr<JSContext>& context) {
  auto* performance = Performance::instance(context.get());
  context->defineGlobalProperty("performance", performance->jsObject);
}

using namespace std::chrono;

IMPL_PROPERTY_GETTER(PerformanceEntry, name)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* entry = static_cast<PerformanceEntry*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewString(ctx, entry->m_nativePerformanceEntry->name);
}

IMPL_PROPERTY_GETTER(PerformanceEntry, entryType)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* entry = static_cast<PerformanceEntry*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewString(ctx, entry->m_nativePerformanceEntry->entryType);
}

IMPL_PROPERTY_GETTER(PerformanceEntry, startTime)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* entry = static_cast<PerformanceEntry*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewUint32(ctx, entry->m_nativePerformanceEntry->startTime);
}

IMPL_PROPERTY_GETTER(PerformanceEntry, duration)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* entry = static_cast<PerformanceEntry*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewUint32(ctx, entry->m_nativePerformanceEntry->duration);
}

IMPL_PROPERTY_GETTER(Performance, timeOrigin)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  int64_t time = std::chrono::duration_cast<std::chrono::milliseconds>(performance->m_context->timeOrigin.time_since_epoch()).count();
  return JS_NewUint32(ctx, time);
}

JSValue Performance::now(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, performance->internalNow());
}
JSValue Performance::toJSON(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  double now = performance->internalNow();
  int64_t timeOrigin = std::chrono::duration_cast<std::chrono::milliseconds>(performance->m_context->timeOrigin.time_since_epoch()).count();

  JSValue object = JS_NewObject(ctx);
  JS_SetPropertyStr(ctx, object, "now", JS_NewFloat64(ctx, now));
  JS_SetPropertyStr(ctx, object, "timeOrigin", JS_NewUint32(ctx, timeOrigin));
  return object;
}

static JSValue buildPerformanceEntry(const std::string& entryType, JSContext* context, NativePerformanceEntry* nativePerformanceEntry) {
  if (entryType == "mark") {
    auto* mark = new PerformanceMark(context, nativePerformanceEntry);
    return mark->jsObject;
  } else if (entryType == "measure") {
    auto* measure = new PerformanceMeasure(context, nativePerformanceEntry);
    return measure->jsObject;
  }
  return JS_NULL;
}

JSValue Performance::clearMarks(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  JSValue targetMark = JS_NULL;
  if (argc == 1) {
    targetMark = argv[0];
  }

  auto* entries = performance->m_nativePerformance.entries;
  auto it = std::begin(*entries);

  while (it != entries->end()) {
    char* entryType = (*it)->entryType;
    if (strcmp(entryType, "mark") == 0) {
      if (JS_IsNull(targetMark)) {
        entries->erase(it);
      } else {
        std::string entryName = (*it)->name;
        std::string targetName = jsValueToStdString(ctx, targetMark);
        if (entryName == targetName) {
          entries->erase(it);
        } else {
          it++;
        };
      }
    } else {
      it++;
    }
  }

  return JS_NULL;
}
JSValue Performance::clearMeasures(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  JSValue targetMark = JS_NULL;
  if (argc == 1) {
    targetMark = argv[0];
  }

  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  auto entries = performance->m_nativePerformance.entries;
  auto it = std::begin(*entries);

  while (it != entries->end()) {
    char* entryType = (*it)->entryType;
    if (strcmp(entryType, "measure") == 0) {
      if (JS_IsNull(targetMark)) {
        entries->erase(it);
      } else {
        std::string entryName = (*it)->name;
        std::string targetName = jsValueToStdString(ctx, targetMark);
        if (entryName == targetName) {
          entries->erase(it);
        } else {
          it++;
        }
      }
    } else {
      it++;
    }
  }

  return JS_NULL;
}
JSValue Performance::getEntries(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  auto entries = performance->getFullEntries();

  size_t entriesSize = entries.size();
  JSValue returnArray = JS_NewArray(ctx);
  JSValue pushMethod = JS_GetPropertyStr(ctx, returnArray, "push");

  for (size_t i = 0; i < entriesSize; i++) {
    auto& entry = entries[i];
    auto entryType = std::string(entry->entryType);
    JSValue v = buildPerformanceEntry(entryType, performance->m_context, entry);
    JS_Call(ctx, pushMethod, returnArray, 1, &v);
    JS_FreeValue(ctx, v);
  }

  JS_FreeValue(ctx, pushMethod);
  return returnArray;
}
JSValue Performance::getEntriesByName(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc == 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'getEntriesByName' on 'Performance': 1 argument required, but only 0 present.");
  }

  std::string targetName = jsValueToStdString(ctx, argv[0]);
  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  auto entries = performance->getFullEntries();
  JSValue targetEntriesArray = JS_NewArray(ctx);
  JSValue pushMethod = JS_GetPropertyStr(ctx, targetEntriesArray, "push");

  for (auto& m_entries : entries) {
    if (m_entries->name == targetName) {
      std::string entryType = std::string(m_entries->entryType);
      JSValue entry = buildPerformanceEntry(entryType, performance->m_context, m_entries);
      JS_Call(ctx, pushMethod, targetEntriesArray, 1, &entry);
    }
  }

  JS_FreeValue(ctx, pushMethod);
  return targetEntriesArray;
}
JSValue Performance::getEntriesByType(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc == 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'getEntriesByName' on 'Performance': 1 argument required, but only 0 present.");
  }

  std::string entryType = jsValueToStdString(ctx, argv[0]);
  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  auto entries = performance->getFullEntries();
  JSValue targetEntriesArray = JS_NewArray(ctx);
  JSValue pushMethod = JS_GetPropertyStr(ctx, targetEntriesArray, "push");

  for (auto& m_entries : entries) {
    if (m_entries->entryType == entryType) {
      JSValue entry = buildPerformanceEntry(entryType, performance->m_context, m_entries);
      JS_Call(ctx, pushMethod, targetEntriesArray, 1, &entry);
    }
  }

  JS_FreeValue(ctx, pushMethod);
  return targetEntriesArray;
}
JSValue Performance::mark(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'mark' on 'Performance': 1 argument required, but only 0 present.");
  }

  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  std::string markName = jsValueToStdString(ctx, argv[0]);
  performance->m_nativePerformance.mark(markName);

  return JS_NULL;
}
JSValue Performance::measure(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc == 0) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'measure' on 'Performance': 1 argument required, but only 0 present.");
  }

  std::string name = jsValueToStdString(ctx, argv[0]);
  std::string startMark;
  std::string endMark;

  if (argc > 1) {
    if (!JS_IsUndefined(argv[1])) {
      startMark = jsValueToStdString(ctx, argv[1]);
    }
  }

  if (argc > 2) {
    endMark = jsValueToStdString(ctx, argv[2]);
  }

  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  JSValue exception = JS_NULL;
  performance->internalMeasure(name, startMark, endMark, &exception);

  if (!JS_IsNull(exception))
    return exception;

  return JS_NULL;
}

PerformanceEntry::PerformanceEntry(JSContext* context, NativePerformanceEntry* nativePerformanceEntry) : HostObject(context, "PerformanceEntry"), m_nativePerformanceEntry(nativePerformanceEntry) {}

PerformanceMark::PerformanceMark(JSContext* context, std::string& name, int64_t startTime)
    : PerformanceEntry(context, new NativePerformanceEntry(name, "mark", startTime, 0, PERFORMANCE_ENTRY_NONE_UNIQUE_ID)) {}
PerformanceMark::PerformanceMark(JSContext* context, NativePerformanceEntry* nativePerformanceEntry) : PerformanceEntry(context, nativePerformanceEntry) {}
PerformanceMeasure::PerformanceMeasure(JSContext* context, std::string& name, int64_t startTime, int64_t duration)
    : PerformanceEntry(context, new NativePerformanceEntry(name, "measure", startTime, duration, PERFORMANCE_ENTRY_NONE_UNIQUE_ID)) {}
PerformanceMeasure::PerformanceMeasure(JSContext* context, NativePerformanceEntry* nativePerformanceEntry) : PerformanceEntry(context, nativePerformanceEntry) {}
void NativePerformance::mark(const std::string& markName) {
  int64_t startTime = std::chrono::duration_cast<microseconds>(system_clock::now().time_since_epoch()).count();
  auto* nativePerformanceEntry = new NativePerformanceEntry{markName, "mark", startTime, 0, PERFORMANCE_ENTRY_NONE_UNIQUE_ID};
  entries->emplace_back(nativePerformanceEntry);
}
void NativePerformance::mark(const std::string& markName, int64_t startTime) {
  auto* nativePerformanceEntry = new NativePerformanceEntry{markName, "mark", startTime, 0, PERFORMANCE_ENTRY_NONE_UNIQUE_ID};
  entries->emplace_back(nativePerformanceEntry);
}

Performance::Performance(JSContext* context) : HostObject(context, "Performance") {}
void Performance::internalMeasure(const std::string& name, const std::string& startMark, const std::string& endMark, JSValue* exception) {
  auto entries = getFullEntries();

  if (!startMark.empty() && !endMark.empty()) {
    size_t startMarkCount = std::count_if(entries.begin(), entries.end(), [&startMark](NativePerformanceEntry* entry) -> bool { return entry->name == startMark; });

    if (startMarkCount == 0) {
      *exception = JS_ThrowTypeError(m_ctx, "Failed to execute 'measure' on 'Performance': The mark %s does not exist.", startMark.c_str());
      return;
    }

    size_t endMarkCount = std::count_if(entries.begin(), entries.end(), [&endMark](NativePerformanceEntry* entry) -> bool { return entry->name == endMark; });

    if (endMarkCount == 0) {
      *exception = JS_ThrowTypeError(m_ctx, "Failed to execute 'measure' on 'Performance': The mark %s does not exist.", endMark.c_str());
      return;
    }

    if (startMarkCount != endMarkCount) {
      *exception = JS_ThrowTypeError(m_ctx, "Failed to execute 'measure' on 'Performance': The mark %s and %s does not appear the same number of times", startMark.c_str(), endMark.c_str());
      return;
    }

    auto startIt = std::begin(entries);
    auto endIt = std::begin(entries);

    for (size_t i = 0; i < startMarkCount; i++) {
      auto startEntry = std::find_if(startIt, entries.end(), [&startMark](NativePerformanceEntry* entry) -> bool { return entry->name == startMark; });

      bool isStartEntryHasUniqueId = (*startEntry)->uniqueId != PERFORMANCE_ENTRY_NONE_UNIQUE_ID;

      auto endEntryComparator = [&endMark, &startEntry, isStartEntryHasUniqueId](NativePerformanceEntry* entry) -> bool {
        if (isStartEntryHasUniqueId) {
          return entry->uniqueId == (*startEntry)->uniqueId && entry->name == endMark;
        }
        return entry->name == endMark;
      };

      auto endEntry = std::find_if(startEntry, entries.end(), endEntryComparator);

      if (endEntry == entries.end()) {
        size_t startIndex = startEntry - entries.begin();
        assert_m(false, ("Can not get endEntry. startIndex: " + std::to_string(startIndex) + " startMark: " + startMark + " endMark: " + endMark));
      }

      int64_t duration = (*endEntry)->startTime - (*startEntry)->startTime;
      int64_t startTime = std::chrono::duration_cast<microseconds>(system_clock::now().time_since_epoch()).count();
      auto* nativePerformanceEntry = new NativePerformanceEntry{name, "measure", startTime, duration, PERFORMANCE_ENTRY_NONE_UNIQUE_ID};
      m_nativePerformance.entries->emplace_back(nativePerformanceEntry);
      startIt = ++startEntry;
      endIt = ++endEntry;
    }
  }
}
double Performance::internalNow() {
  auto now = std::chrono::system_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::microseconds>(now - m_context->timeOrigin);
  auto reducedDuration = std::floor(duration / 1000us) * 1000us;
  return std::chrono::duration_cast<std::chrono::milliseconds>(reducedDuration).count();
}
std::vector<NativePerformanceEntry*> Performance::getFullEntries() {
  auto* bridgeEntries = m_nativePerformance.entries;
#if ENABLE_PROFILE
  if (getDartMethod()->getPerformanceEntries == nullptr) {
    return std::vector<NativePerformanceEntry*>();
  }
  auto dartEntryList = getDartMethod()->getPerformanceEntries(m_context->getContextId());
  if (dartEntryList == nullptr)
    return std::vector<NativePerformanceEntry*>();
  auto dartEntityBytes = dartEntryList->entries;
  std::vector<NativePerformanceEntry*> dartEntries;
  dartEntries.reserve(dartEntryList->length);

  for (size_t i = 0; i < dartEntryList->length * 3; i += 3) {
    const char* name = reinterpret_cast<const char*>(dartEntityBytes[i]);
    int64_t startTime = dartEntityBytes[i + 1];
    int64_t uniqueId = dartEntityBytes[i + 2];
    auto* nativePerformanceEntry = new NativePerformanceEntry(name, "mark", startTime, 0, uniqueId);
    dartEntries.emplace_back(nativePerformanceEntry);
  }
#endif

  std::vector<NativePerformanceEntry*> mergedEntries;

  mergedEntries.insert(mergedEntries.end(), bridgeEntries->begin(), bridgeEntries->end());
#if ENABLE_PROFILE
  mergedEntries.insert(mergedEntries.end(), dartEntries.begin(), dartEntries.end());
  delete[] dartEntryList->entries;
  delete dartEntryList;
#endif

  return mergedEntries;
}

#if ENABLE_PROFILE

void Performance::measureSummary(JSValue* exception) {
  internalMeasure(PERF_WIDGET_CREATION_COST, PERF_CONTROLLER_INIT_START, PERF_CONTROLLER_INIT_END, exception);
  internalMeasure(PERF_CONTROLLER_PROPERTIES_INIT_COST, PERF_CONTROLLER_INIT_START, PERF_CONTROLLER_PROPERTY_INIT, exception);
  internalMeasure(PERF_VIEW_CONTROLLER_PROPERTIES_INIT_COST, PERF_VIEW_CONTROLLER_INIT_START, PERF_VIEW_CONTROLLER_PROPERTY_INIT, exception);
  internalMeasure(PERF_BRIDGE_INIT_COST, PERF_BRIDGE_INIT_START, PERF_BRIDGE_INIT_END, exception);
  internalMeasure(PERF_BRIDGE_REGISTER_DART_METHOD_COST, PERF_BRIDGE_REGISTER_DART_METHOD_START, PERF_BRIDGE_REGISTER_DART_METHOD_END, exception);
  internalMeasure(PERF_CREATE_VIEWPORT_COST, PERF_CREATE_VIEWPORT_START, PERF_CREATE_VIEWPORT_END, exception);
  internalMeasure(PERF_ELEMENT_MANAGER_INIT_COST, PERF_ELEMENT_MANAGER_INIT_START, PERF_ELEMENT_MANAGER_INIT_END, exception);
  internalMeasure(PERF_ELEMENT_MANAGER_PROPERTIES_INIT_COST, PERF_ELEMENT_MANAGER_INIT_START, PERF_ELEMENT_MANAGER_PROPERTY_INIT, exception);
  internalMeasure(PERF_ROOT_ELEMENT_INIT_COST, PERF_ROOT_ELEMENT_INIT_START, PERF_ROOT_ELEMENT_INIT_END, exception);
  internalMeasure(PERF_ROOT_ELEMENT_PROPERTIES_INIT_COST, PERF_ROOT_ELEMENT_INIT_START, PERF_ROOT_ELEMENT_PROPERTY_INIT, exception);
  internalMeasure(PERF_JS_CONTEXT_INIT_COST, PERF_JS_CONTEXT_INIT_START, PERF_JS_CONTEXT_INIT_END, exception);
  internalMeasure(PERF_JS_HOST_CLASS_GET_PROPERTY_COST, PERF_JS_HOST_CLASS_GET_PROPERTY_START, PERF_JS_HOST_CLASS_GET_PROPERTY_END, exception);
  internalMeasure(PERF_JS_HOST_CLASS_SET_PROPERTY_COST, PERF_JS_HOST_CLASS_SET_PROPERTY_START, PERF_JS_HOST_CLASS_SET_PROPERTY_END, exception);
  internalMeasure(PERF_JS_HOST_CLASS_INIT_COST, PERF_JS_HOST_CLASS_INIT_START, PERF_JS_HOST_CLASS_INIT_END, exception);
  internalMeasure(PERF_JS_NATIVE_FUNCTION_CALL_COST, PERF_JS_NATIVE_FUNCTION_CALL_START, PERF_JS_NATIVE_FUNCTION_CALL_END, exception);
  internalMeasure(PERF_JS_NATIVE_METHOD_INIT_COST, PERF_JS_NATIVE_METHOD_INIT_START, PERF_JS_NATIVE_METHOD_INIT_END, exception);
  internalMeasure(PERF_JS_POLYFILL_INIT_COST, PERF_JS_POLYFILL_INIT_START, PERF_JS_POLYFILL_INIT_END, exception);
  internalMeasure(PERF_JS_BUNDLE_LOAD_COST, PERF_JS_BUNDLE_LOAD_START, PERF_JS_BUNDLE_LOAD_END, exception);
  internalMeasure(PERF_JS_BUNDLE_EVAL_COST, PERF_JS_BUNDLE_EVAL_START, PERF_JS_BUNDLE_EVAL_END, exception);
  internalMeasure(PERF_FLUSH_UI_COMMAND_COST, PERF_FLUSH_UI_COMMAND_START, PERF_FLUSH_UI_COMMAND_END, exception);
  internalMeasure(PERF_CREATE_ELEMENT_COST, PERF_CREATE_ELEMENT_START, PERF_CREATE_ELEMENT_END, exception);
  internalMeasure(PERF_CREATE_TEXT_NODE_COST, PERF_CREATE_TEXT_NODE_START, PERF_CREATE_TEXT_NODE_END, exception);
  internalMeasure(PERF_CREATE_COMMENT_COST, PERF_CREATE_COMMENT_START, PERF_CREATE_COMMENT_END, exception);
  internalMeasure(PERF_DISPOSE_EVENT_TARGET_COST, PERF_DISPOSE_EVENT_TARGET_START, PERF_DISPOSE_EVENT_TARGET_END, exception);
  internalMeasure(PERF_ADD_EVENT_COST, PERF_ADD_EVENT_START, PERF_ADD_EVENT_END, exception);
  internalMeasure(PERF_INSERT_ADJACENT_NODE_COST, PERF_INSERT_ADJACENT_NODE_START, PERF_INSERT_ADJACENT_NODE_END, exception);
  internalMeasure(PERF_REMOVE_NODE_COST, PERF_REMOVE_NODE_START, PERF_REMOVE_NODE_END, exception);
  internalMeasure(PERF_SET_STYLE_COST, PERF_SET_STYLE_START, PERF_SET_STYLE_END, exception);
  internalMeasure(PERF_SET_PROPERTIES_COST, PERF_SET_PROPERTIES_START, PERF_SET_PROPERTIES_END, exception);
  internalMeasure(PERF_REMOVE_PROPERTIES_COST, PERF_REMOVE_PROPERTIES_START, PERF_REMOVE_PROPERTIES_END, exception);
  internalMeasure(PERF_FLEX_LAYOUT_COST, PERF_FLEX_LAYOUT_START, PERF_FLEX_LAYOUT_END, exception);
  internalMeasure(PERF_FLOW_LAYOUT_COST, PERF_FLOW_LAYOUT_START, PERF_FLOW_LAYOUT_END, exception);
  internalMeasure(PERF_INTRINSIC_LAYOUT_COST, PERF_INTRINSIC_LAYOUT_START, PERF_INTRINSIC_LAYOUT_END, exception);
  internalMeasure(PERF_SILVER_LAYOUT_COST, PERF_SILVER_LAYOUT_START, PERF_SILVER_LAYOUT_END, exception);
  internalMeasure(PERF_PAINT_COST, PERF_PAINT_START, PERF_PAINT_END, exception);
  internalMeasure(PERF_DOM_FORCE_LAYOUT_COST, PERF_DOM_FORCE_LAYOUT_START, PERF_DOM_FORCE_LAYOUT_END, exception);
  internalMeasure(PERF_DOM_FLUSH_UI_COMMAND_COST, PERF_DOM_FLUSH_UI_COMMAND_START, PERF_DOM_FLUSH_UI_COMMAND_END, exception);
  internalMeasure(PERF_JS_PARSE_TIME_COST, PERF_JS_PARSE_TIME_START, PERF_JS_PARSE_TIME_END, exception);
}

std::vector<NativePerformanceEntry*> findAllMeasures(const std::vector<NativePerformanceEntry*>& entries, const std::string& targetName) {
  std::vector<NativePerformanceEntry*> resultEntries;

  for (auto entry : entries) {
    if (entry->name == targetName) {
      resultEntries.emplace_back(entry);
    }
  }

  return resultEntries;
};

double getMeasureTotalDuration(const std::vector<NativePerformanceEntry*>& measures) {
  double duration = 0.0;
  for (auto entry : measures) {
    duration += entry->duration;
  }
  return duration / 1000;
}

JSValue Performance::__kraken_navigation_summary__(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* performance = static_cast<Performance*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  JSValue exception = JS_NULL;
  performance->measureSummary(&exception);

  std::vector<NativePerformanceEntry*> entries = performance->getFullEntries();

  if (entries.empty()) {
    return JS_ThrowTypeError(ctx, "Failed to get navigation summary: flutter is not running in profile mode.");
  }

  std::vector<NativePerformanceEntry*> measures;
  for (auto& m_entries : entries) {
    if (std::string(m_entries->entryType) == "measure") {
      measures.emplace_back(m_entries);
    }
  }

#define GET_COST_WITH_DECREASE(NAME, MACRO, DECREASE)                       \
  auto NAME##Measures = findAllMeasures(measures, MACRO);                   \
  size_t NAME##Count = NAME##Measures.size();                               \
  double NAME##Cost = getMeasureTotalDuration(NAME##Measures) - (DECREASE); \
  auto NAME##Avg = NAME##Measures.empty() ? 0 : (NAME##Cost) / NAME##Measures.size();

#define GET_COST(NAME, MACRO)                                  \
  auto NAME##Measures = findAllMeasures(measures, MACRO);      \
  size_t NAME##Count = NAME##Measures.size();                  \
  double NAME##Cost = getMeasureTotalDuration(NAME##Measures); \
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
  GET_COST_WITH_DECREASE(jsHostClassGetProperty, PERF_JS_HOST_CLASS_GET_PROPERTY_COST, domForceLayoutCost + domFlushUICommandCost)
  GET_COST(jsHostClassSetProperty, PERF_JS_HOST_CLASS_SET_PROPERTY_COST);
  GET_COST(jsHostClassInit, PERF_JS_HOST_CLASS_INIT_COST);
  GET_COST(jsNativeFunction, PERF_JS_NATIVE_FUNCTION_CALL_COST);
  GET_COST_WITH_DECREASE(jsBundleEval, PERF_JS_BUNDLE_EVAL_COST, domForceLayoutCost + domFlushUICommandCost);

  double initBundleCost = jsBundleLoadCost + jsBundleEvalCost + flushUiCommandCost + createElementCost + createTextNodeCost + createCommentCost + disposeEventTargetCost + addEventCost +
                          insertAdjacentNodeCost + removeNodeCost + setStyleCost + setPropertiesCost + removePropertiesCost;
  // layout and paint measure are not correct.
  double renderingCost = flexLayoutCost + flowLayoutCost + intrinsicLayoutCost + silverLayoutCost + paintCost;
  double totalCost = widgetCreationCost + initBundleCost;

  char buffer[5000];
  // clang-format off
  sprintf(buffer, R"(
Total time cost(without paint and layout): %.*fms

%s: %.*fms
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
  + %s %.*fms avg: %.*fms count: %zu
  + %s %.*fms avg: %.*fms count: %zu
Rendering: %.*fms
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
          PERF_JS_HOST_CLASS_INIT_COST, 2, jsHostClassInitCost, 2, jsHostClassInitAvg, jsHostClassInitCount,
          PERF_JS_NATIVE_FUNCTION_CALL_COST, 2, jsNativeFunctionCost, 2, jsNativeFunctionAvg, jsNativeFunctionCount,
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
          PERF_REMOVE_PROPERTIES_COST, 2, removePropertiesCost, 2, removePropertiesAvg, removePropertiesCount,
          2, renderingCost,
          PERF_FLEX_LAYOUT_COST, 2, flexLayoutCost, 2, flexLayoutAvg, flexLayoutCount,
          PERF_FLOW_LAYOUT_COST, 2, flowLayoutCost, 2, flowLayoutAvg, flowLayoutCount,
          PERF_INTRINSIC_LAYOUT_COST, 2, intrinsicLayoutCost, 2, intrinsicLayoutAvg, intrinsicLayoutCount,
          PERF_SILVER_LAYOUT_COST, 2, silverLayoutCost, 2, silverLayoutAvg, silverLayoutCount,
          PERF_PAINT_COST, 2, paintCost, 2, paintAvg, paintCount
  );
  // clang-format on
  return JS_NewString(ctx, buffer);
}

#endif

}  // namespace kraken::binding::qjs
