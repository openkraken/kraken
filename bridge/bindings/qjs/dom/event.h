/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_EVENT_H
#define KRAKENBRIDGE_EVENT_H

#include "bindings/qjs/host_class.h"

namespace kraken::binding::qjs {

void bindEvent(std::unique_ptr<JSContext> &context);

class EventInstance;

using EventCreator = EventInstance *(*)(JSContext *context, void *nativeEvent);

class Event : public HostClass {
public:
  static JSClassID kEventClassID;

  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;
  Event() = delete;
  explicit Event(JSContext *context);

  static EventInstance *buildEventInstance(std::string &eventType, JSContext *context, void *nativeEvent,
                                           bool isCustomEvent);

private:
  static std::unordered_map<std::string, EventCreator> m_eventCreatorMap;
  OBJECT_INSTANCE(Event);
  DEFINE_HOST_CLASS_PROPERTY(10, Type, Bubbles, Cancelable, Timestamp, DefaultPrevented, Target, SrcElement, CurrentTarget, ReturnValue, CancelBubble)
};

struct NativeEvent {
  NativeString *type{nullptr};
  int64_t bubbles{0};
  int64_t cancelable{0};
  int64_t timeStamp{0};
  int64_t defaultPrevented{0};
  // The pointer address of target EventTargetInstance object.
  void *target{nullptr};
  // The pointer address of current target EventTargetInstance object.
  void *currentTarget{nullptr};
};

struct RawEvent {
  uint64_t *bytes;
  int64_t length;
};

class EventInstance : public Instance {
public:
  EventInstance() = delete;
  ~EventInstance() override {
    delete nativeEvent;
  }

  static EventInstance *fromNativeEvent(Event *event, NativeEvent *nativeEvent);
  NativeEvent *nativeEvent{nullptr};

  inline const bool propagationStopped() { return m_propagationStopped; }
  inline const bool cancelled() { return m_cancelled; }
  inline void cancelled(bool v) { m_cancelled = v; }
  inline const bool propagationImmediatelyStopped() { return m_propagationImmediatelyStopped; }
protected:
  explicit EventInstance(Event *jsEvent, std::string eventType, JSValue eventInit);
  explicit EventInstance(Event *jsEvent, NativeEvent *nativeEvent);
  bool m_cancelled{false};
  bool m_propagationStopped{false};
  bool m_propagationImmediatelyStopped{false};

private:
  static void finalizer(JSRuntime *rt, JSValue val);
};

}

#endif // KRAKENBRIDGE_EVENT_H
