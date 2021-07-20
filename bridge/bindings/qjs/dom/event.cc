/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "bindings/qjs/qjs_patch.h"
#include "custom_event.h"
#include "kraken_bridge.h"
#include "event_target.h"

namespace kraken::binding::qjs {

std::once_flag kEventInitOnceFlag;

void bindEvent(std::unique_ptr<JSContext> &context) {
  auto *constructor = new Event(context.get());
  context->defineGlobalProperty("Event", constructor->classObject);
}

JSClassID Event::kEventClassID{0};

Event::Event(JSContext *context) : HostClass(context, "Event") {
  std::call_once(kEventInitOnceFlag, []() {
    JS_NewClassID(&kEventClassID);
  });
}

JSValue Event::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return HostClass::constructor(ctx, func_obj, this_val, argc, argv);
}

OBJECT_INSTANCE_IMPL(Event);
std::unordered_map<std::string, EventCreator> Event::m_eventCreatorMap{};

PROP_GETTER(Event, Type)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewUnicodeString(eventInstance->context()->runtime(), eventInstance->context()->ctx(),
                             eventInstance->nativeEvent->type->string, eventInstance->nativeEvent->type->length);
}
PROP_SETTER(Event, Type)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, Bubbles)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->nativeEvent->bubbles);
}
PROP_SETTER(Event, Bubbles)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, Cancelable)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->nativeEvent->cancelable);
}
PROP_SETTER(Event, Cancelable)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, Timestamp)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewInt64(ctx, eventInstance->nativeEvent->timeStamp);
}
PROP_SETTER(Event, Timestamp)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, DefaultPrevented)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->cancelled());
}
PROP_SETTER(Event, DefaultPrevented)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, Target)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  if (eventInstance->nativeEvent->target != nullptr) {
    auto instance = reinterpret_cast<EventTargetInstance *>(eventInstance->nativeEvent->target);
    return instance->instanceObject;
  }
  return JS_NULL;
}
PROP_SETTER(Event, Target)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, SrcElement)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  if (eventInstance->nativeEvent->target != nullptr) {
    auto instance = reinterpret_cast<EventTargetInstance *>(eventInstance->nativeEvent->target);
    return instance->instanceObject;
  }
  return JS_NULL;
}
PROP_SETTER(Event, SrcElement)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, CurrentTarget)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  if (eventInstance->nativeEvent->currentTarget != nullptr) {
    auto instance = reinterpret_cast<EventTargetInstance *>(eventInstance->nativeEvent->currentTarget);
    return instance->instanceObject;
  }
  return JS_NULL;
}
PROP_SETTER(Event, CurrentTarget)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, ReturnValue)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, !eventInstance->cancelled());
}
PROP_SETTER(Event, ReturnValue)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, CancelBubble)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->cancelled());
}
PROP_SETTER(Event, CancelBubble)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc == 0) return JS_NULL;

  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  bool v = JS_ToBool(ctx, argv[0]);
  if (v) {
    eventInstance->cancelled(v);
  }
  return JS_NULL;
}

EventInstance *Event::buildEventInstance(std::string &eventType, JSContext *context, void *nativeEvent,
                                         bool isCustomEvent) {
  EventInstance *eventInstance;
  if (isCustomEvent) {
    eventInstance =
      new CustomEventInstance(CustomEvent::instance(context), reinterpret_cast<NativeCustomEvent *>(nativeEvent));
  } else if (m_eventCreatorMap.count(eventType) > 0) {
    eventInstance = m_eventCreatorMap[eventType](context, nativeEvent);
  } else {
    eventInstance = new EventInstance(Event::instance(context), reinterpret_cast<NativeEvent *>(nativeEvent));
  }

  return eventInstance;
}

EventInstance::EventInstance(Event *event, NativeEvent *nativeEvent)
  : nativeEvent(nativeEvent), Instance(event, "Event", Event::kEventClassID, finalizer) {}
EventInstance::EventInstance(Event *jsEvent, std::string eventType, JSValue eventInit) : Instance(jsEvent, "Event",
                                                                                                  Event::kEventClassID,
                                                                                                  finalizer) {
  nativeEvent = new NativeEvent(stringToNativeString(eventType));
  auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
  nativeEvent->timeStamp = ms.count();

  if (!JS_IsNull(eventInit)) { ;
    JSAtom bubblesKey = JS_NewAtom(m_ctx, "bubbles");
    if (JS_HasProperty(m_ctx, eventInit, bubblesKey)) {
      nativeEvent->bubbles = JS_ToBool(m_ctx, JS_GetProperty(m_ctx, eventInit, bubblesKey));
    }
    JS_FreeAtom(m_ctx, bubblesKey);

    JSAtom cancelableKey = JS_NewAtom(m_ctx, "cancelable");
    if (JS_HasProperty(m_ctx, eventInit, cancelableKey)) {
      nativeEvent->cancelable = JS_ToBool(m_ctx, JS_GetProperty(m_ctx, eventInit, cancelableKey));
    }
    JS_FreeAtom(m_ctx, cancelableKey);
  }
}

void EventInstance::finalizer(JSRuntime *rt, JSValue val) {
  auto *event = static_cast<EventInstance *>(JS_GetOpaque(val, EventTarget::kEventTargetClassID));
  if (event->context()->isValid()) {
    JS_FreeValue(event->m_ctx, event->instanceObject);
  }
  delete event;
}

} // namespace kraken::binding::qjs
