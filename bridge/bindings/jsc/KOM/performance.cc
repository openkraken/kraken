/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "performance.h"
#include <chrono>
#include <cmath>

namespace kraken::binding::jsc {

using namespace std::chrono;

JSPerformanceEntry::JSPerformanceEntry(JSContext *context, JSStringRef name, JSStringRef entryType, double startTime,
                                       double duration)
  : HostObject(context, "PerformanceEntry"), m_startTime(startTime), m_duration(duration) {
  m_name.setString(name);
  m_entryType.setString(entryType);
}

JSValueRef JSPerformanceEntry::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getPerformanceEntryPropertyMap();
  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];
    switch (property) {
    case PerformanceEntryProperty::kName:
      return m_name.makeString();
    case PerformanceEntryProperty::kEntryType:
      return m_entryType.makeString();
    case PerformanceEntryProperty::kStartTime:
      return JSValueMakeNumber(ctx, m_startTime);
    case PerformanceEntryProperty::kDuration:
      return JSValueMakeNumber(ctx, m_duration);
    }
  }
  return nullptr;
}

std::unordered_map<std::string, JSPerformanceEntry::PerformanceEntryProperty> &
JSPerformanceEntry::getPerformanceEntryPropertyMap() {
  static std::unordered_map<std::string, PerformanceEntryProperty> propertyMap{
    {"name", PerformanceEntryProperty::kName},
    {"entryType", PerformanceEntryProperty::kEntryType},
    {"startTime", PerformanceEntryProperty::kStartTime},
    {"duration", PerformanceEntryProperty::kDuration}};
  return propertyMap;
}

std::vector<JSStringRef> &JSPerformanceEntry::getPerformanceEntryPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("name"), JSStringCreateWithUTF8CString("entryType"),
    JSStringCreateWithUTF8CString("startTime"), JSStringCreateWithUTF8CString("duration")};
  return propertyNames;
}

JSPerformanceMark::JSPerformanceMark(JSContext *context, JSStringRef name, double startTime)
  : JSPerformanceEntry(context, name, JSStringCreateWithUTF8CString("mark"), startTime, 0) {}

JSPerformanceMeasure::JSPerformanceMeasure(JSContext *context, JSStringRef name, double startTime, double duration)
  : JSPerformanceEntry(context, name, JSStringCreateWithUTF8CString("measure"), startTime, duration) {}

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

void JSPerformanceEntry::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getPerformanceEntryPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
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
  auto entriesStart = std::begin(performance->m_entries);
  auto entriesEnd = std::end(performance->m_entries);

  while (entriesStart != entriesEnd) {
    std::string entryType = (*entriesStart)->m_entryType.string();
    if (entryType == "mark") {
      if (targetMark == nullptr) {
        performance->m_entries.erase(entriesStart);
      } else {
        std::string entryName = (*entriesStart)->m_name.string();
        std::string targetName = JSStringToStdString(JSValueToStringCopy(ctx, targetMark, exception));
        if (entryName == targetName) {
          performance->m_entries.erase(entriesStart);
        }
      }
    }

    entriesStart++;
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
  auto entriesStart = std::begin(performance->m_entries);
  auto entriesEnd = std::end(performance->m_entries);

  while (entriesStart != entriesEnd) {
    std::string entryType = (*entriesStart)->m_entryType.string();
    if (entryType == "measure") {
      if (targetMark == nullptr) {
        performance->m_entries.erase(entriesStart);
      } else {
        std::string entryName = (*entriesStart)->m_name.string();
        std::string targetName = JSStringToStdString(JSValueToStringCopy(ctx, targetMark, exception));
        if (entryName == targetName) {
          performance->m_entries.erase(entriesStart);
        }
      }
    }

    entriesStart++;
  }

  return nullptr;
}

JSValueRef JSPerformance::getEntries(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  size_t entriesSize = performance->m_entries.size();
  JSValueRef args[entriesSize];

  for (size_t i = 0; i < entriesSize; i ++) {
    args[0] = performance->m_entries[i]->jsObject;
  }

  JSObjectRef entriesArray = JSObjectMakeArray(ctx, entriesSize, args, exception);
  return entriesArray;
}

JSValueRef JSPerformance::getEntriesByName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'getEntriesByName' on 'Performance': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef targetName = JSValueToStringCopy(ctx, arguments[0], exception);

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  std::vector<JSObjectRef> entries;

  for (auto & m_entries : performance->m_entries) {
    if (JSStringIsEqual(m_entries->m_name.getString(), targetName)) {
      entries.emplace_back(m_entries->jsObject);
    }
  }

  return JSObjectMakeArray(ctx, entries.size(), entries.data(), exception);
}

JSValueRef JSPerformance::getEntriesByType(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'getEntriesByName' on 'Performance': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef targetName = JSValueToStringCopy(ctx, arguments[0], exception);

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  std::vector<JSObjectRef> entries;

  for (auto & m_entries : performance->m_entries) {
    if (JSStringIsEqual(m_entries->m_entryType.getString(), targetName)) {
      entries.emplace_back(m_entries->jsObject);
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
  JSStringRef markRef = JSValueToStringCopy(ctx, arguments[0], exception);

  auto startTime = std::chrono::duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
  auto mark = new JSPerformanceMark(performance->context, markRef, startTime);
  performance->m_entries.emplace_back(mark);

  return nullptr;
}

JSValueRef JSPerformance::measure(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 0) {
    JSC_THROW_ERROR(ctx, "Failed to execute 'measure' on 'Performance': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  JSStringRef name = JSValueToStringCopy(ctx, arguments[0], exception);
  JSStringRef startMark = nullptr;
  JSStringRef endMark = nullptr;

  if (argumentCount > 1) {
    startMark = JSValueToStringCopy(ctx, arguments[1], exception);
  }

  if (argumentCount > 2) {
    endMark = JSValueToStringCopy(ctx, arguments[2], exception);
  }

  auto performance = reinterpret_cast<JSPerformance *>(JSObjectGetPrivate(thisObject));
  auto entries = performance->m_entries;

  double duration;
  auto now = duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();

  if (startMark && endMark) {
    auto startEntry = std::find_if(entries.begin(), entries.end(), [&startMark](JSPerformanceEntry *entry) -> bool {
      return JSStringIsEqual(entry->m_name.getString(), startMark);
    });
    auto endEntry = std::find_if(entries.begin(), entries.end(), [&endMark](JSPerformanceEntry *entry) -> bool {
      return JSStringIsEqual(entry->m_name.getString(), endMark);
    });
    duration = (*endEntry)->m_duration - (*startEntry)->m_duration;
  } else if (startMark) {
    auto startEntry = std::find_if(entries.begin(), entries.end(), [&startMark](JSPerformanceEntry *entry) -> bool {
      return JSStringIsEqual(entry->m_name.getString(), startMark);
    });
    duration = now - (*startEntry)->m_duration;
  } else if (endMark) {
    auto endEntry = std::find_if(entries.begin(), entries.end(), [&endMark](JSPerformanceEntry *entry) -> bool {
      return JSStringIsEqual(entry->m_name.getString(), endMark);
    });
    duration = (*endEntry)->m_duration - duration_cast<milliseconds>(performance->context->timeOrigin.time_since_epoch()).count();
  } else {
    duration = performance->internalNow();
  }

  auto startTime = std::chrono::duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
  auto measureEntry = new JSPerformanceMeasure(performance->context, name, startTime, duration);
  performance->m_entries.emplace_back(measureEntry);

  return nullptr;
}

void bindPerformance(std::unique_ptr<JSContext> &context) {
  auto performance = new JSPerformance(context.get());
  JSC_GLOBAL_BINDING_HOST_OBJECT(context, "performance", performance);
}
} // namespace kraken::binding::jsc
