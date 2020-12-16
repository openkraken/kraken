/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "performance.h"
#include <chrono>
#include <cmath>
#include "foundation/logging.h"

namespace kraken::binding::jsc {

using namespace std::chrono;

JSObjectRef buildPerformanceEntry(std::string &entryType, JSContext *context, NativePerformanceEntry *nativePerformanceEntry) {
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
  : HostObject(context, "PerformanceEntry") {}

JSValueRef JSPerformanceEntry::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPerformanceEntryPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case PerformanceEntryProperty::name: {
      JSStringRef nameValue = JSStringCreateWithUTF8CString(m_nativePerformanceEntry->name.c_str());
      return JSValueMakeString(ctx, nameValue);
    }
    case PerformanceEntryProperty::entryType: {
      JSStringRef entryValue = JSStringCreateWithUTF8CString(m_nativePerformanceEntry->entryType.c_str());
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

JSPerformanceMark::JSPerformanceMark(JSContext *context, std::string &name, double startTime)
  : JSPerformanceEntry(context, new NativePerformanceEntry(name.c_str(), "mark", startTime, 0)) {}
JSPerformanceMark::JSPerformanceMark(JSContext *context, NativePerformanceEntry *nativePerformanceEntry)
  : JSPerformanceEntry(context, nativePerformanceEntry) {}

JSPerformanceMeasure::JSPerformanceMeasure(JSContext *context, std::string &name, double startTime, double duration)
  : JSPerformanceEntry(context, new NativePerformanceEntry(name.c_str(), "measure", startTime, duration)) {}
JSPerformanceMeasure::JSPerformanceMeasure(JSContext *context, NativePerformanceEntry *nativePerformanceEntry)
  : JSPerformanceEntry(context, nativePerformanceEntry) {}

JSValueRef JSPerformance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPerformancePropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case PerformanceProperty::now: {
      return m_now.function();
    }
    case PerformanceProperty::timeOrigin: {
      double time =
        std::chrono::duration_cast<std::chrono::milliseconds>(context->timeOrigin.time_since_epoch()).count();
      return JSValueMakeNumber(ctx, time);
    }
    case PerformanceProperty::toJSON: {
      return m_toJSON.function();
    }
    case PerformanceProperty::clearMarks:
      return m_clearMarks.function();
    case PerformanceProperty::clearMeasures:
      return m_clearMeasures.function();
    case PerformanceProperty::getEntries:
      return m_getEntries.function();
    case PerformanceProperty::getEntriesByName:
      return m_getEntriesByName.function();
    case PerformanceProperty::getEntriesByType:
      return m_getEntriesByType.function();
    case PerformanceProperty::mark:
      return m_mark.function();
    case PerformanceProperty::measure:
      return m_measure.function();
    }
  }

  return HostObject::getProperty(name, exception);
}

void JSPerformanceEntry::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getPerformanceEntryPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

JSPerformance::~JSPerformance() {
  KRAKEN_LOG(VERBOSE) << "Performance finalized";
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
  auto it = std::begin(performance->m_entries);

  while (it != performance->m_entries.end()) {
    std::string entryType = (*it)->entryType;
    if (entryType == "mark") {
      if (targetMark == nullptr) {
        performance->m_entries.erase(it);
      } else {
        std::string entryName = (*it)->name;
        std::string targetName = JSStringToStdString(JSValueToStringCopy(ctx, targetMark, exception));
        if (entryName == targetName) {
          performance->m_entries.erase(it);
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
  auto it = std::begin(performance->m_entries);

  while (it != performance->m_entries.end()) {
    std::string entryType = (*it)->entryType;
    if (entryType == "measure") {
      if (targetMark == nullptr) {
        performance->m_entries.erase(it);
      } else {
        std::string entryName = (*it)->name;
        std::string targetName = JSStringToStdString(JSValueToStringCopy(ctx, targetMark, exception));
        if (entryName == targetName) {
          performance->m_entries.erase(it);
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
  size_t entriesSize = performance->m_entries.size();
  JSValueRef args[entriesSize];

  for (size_t i = 0; i < entriesSize; i++) {
    auto &entry = performance->m_entries[i];
    auto entryType = std::string(entry->entryType);
    args[i] = buildPerformanceEntry(entryType, performance->context, entry);
  }

  JSObjectRef entriesArray = JSObjectMakeArray(ctx, entriesSize, args, exception);
  return entriesArray;
}

JSValueRef JSPerformance::getEntriesByName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    JSC_THROW_ERROR(ctx,
                    "Failed to execute 'getEntriesByName' on 'Performance': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  JSStringRef targetNameStrRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string targetName = JSStringToStdString(targetNameStrRef);

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  std::vector<JSObjectRef> entries;

  for (auto &m_entries : performance->m_entries) {
    if (m_entries->name == targetName) {
      std::string entryType = std::string(m_entries->entryType);
      auto performanceEntry = buildPerformanceEntry(entryType, performance->context, m_entries);
      entries.emplace_back(performanceEntry);
    }
  }

  return JSObjectMakeArray(ctx, entries.size(), entries.data(), exception);
}

JSValueRef JSPerformance::getEntriesByType(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    JSC_THROW_ERROR(ctx,
                    "Failed to execute 'getEntriesByName' on 'Performance': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  JSStringRef entryTypeStrRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string entryType = JSStringToStdString(entryTypeStrRef);

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  std::vector<JSObjectRef> entries;

  for (auto &m_entries : performance->m_entries) {
    if (m_entries->entryType == entryType) {
      auto performanceEntry = buildPerformanceEntry(entryType, performance->context, m_entries);
      entries.emplace_back(performanceEntry);
    }
  }

  return JSObjectMakeArray(ctx, entries.size(), entries.data(), exception);
}

JSValueRef JSPerformance::mark(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'mark' on 'Performance': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  JSStringRef markNameRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string markName = JSStringToStdString(markNameRef);

  performance->internalMark(markName);

  return nullptr;
}

JSValueRef JSPerformance::measure(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'measure' on 'Performance': 1 argument required, but only 0 present.",
                    exception);
    return nullptr;
  }

  JSStringRef nameStrRef = JSValueToStringCopy(ctx, arguments[0], exception);
  std::string name = JSStringToStdString(nameStrRef);
  std::string startMark;
  std::string endMark;
  bool isStartMarkUndefined = false;

  if (argumentCount > 1) {
    isStartMarkUndefined = JSValueIsUndefined(ctx, arguments[1]);
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
  auto entries = performance->m_entries;

  performance->internalMeasure(startMark, endMark);

  return nullptr;
}

void JSPerformance::internalMark(const std::string &markName) {
  double startTime = std::chrono::duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
  auto *nativePerformanceEntry = new NativePerformanceEntry{markName, "mark", startTime, 0};
  m_entries.emplace_back(nativePerformanceEntry);
}

void JSPerformance::internalMeasure(const std::string &startMark, const std::string &endMark) {
  auto entries = m_entries;
  double duration;
  auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();

  if (!startMark.empty() && !endMark.empty()) {
    auto startEntry = std::find_if(entries.begin(), entries.end(), [&startMark](auto entry) -> bool {
      return startMark == entry->name;
    });
    auto endEntry = std::find_if(entries.begin(), entries.end(), [&endMark](auto entry) -> bool {
      return endMark == entry->name;
    });
    duration = (*endEntry)->duration - (*startEntry)->duration;
  } else if (!startMark.empty()) {
    auto startEntry = std::find_if(entries.begin(), entries.end(), [&startMark](auto entry) -> bool {
      return startMark == entry->name;
    });
    duration = now - (*startEntry)->startTime;
  } else if (!endMark.empty()) {
    auto endEntry = std::find_if(entries.begin(), entries.end(), [&endMark](auto entry) -> bool {
      return endMark == entry->name;
    });
    duration = (*endEntry)->startTime -
               duration_cast<milliseconds>(context->timeOrigin.time_since_epoch()).count();
  } else {
    duration = internalNow();
  }

  double startTime = std::chrono::duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
  auto *nativePerformanceEntry = new NativePerformanceEntry{name, "measure", startTime, duration};
  m_entries.emplace_back(nativePerformanceEntry);
}

void bindPerformance(std::unique_ptr<JSContext> &context) {
  auto performance = new JSPerformance(context.get());
  JSC_GLOBAL_BINDING_HOST_OBJECT(context, "performance", performance);
}
} // namespace kraken::binding::jsc
