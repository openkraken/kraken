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
  auto *constructor = Event::instance(context.get());
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

PROP_GETTER(Event, type)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewUnicodeString(eventInstance->context()->runtime(), eventInstance->context()->ctx(),
                             eventInstance->nativeEvent->type->string, eventInstance->nativeEvent->type->length);
}
PROP_SETTER(Event, type)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, bubbles)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->nativeEvent->bubbles);
}
PROP_SETTER(Event, bubbles)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, cancelable)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->nativeEvent->cancelable);
}
PROP_SETTER(Event, cancelable)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, timestamp)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewInt64(ctx, eventInstance->nativeEvent->timeStamp);
}
PROP_SETTER(Event, timestamp)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, defaultPrevented)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->cancelled());
}
PROP_SETTER(Event, defaultPrevented)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, target)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  if (eventInstance->nativeEvent->target != nullptr) {
    auto instance = reinterpret_cast<EventTargetInstance *>(eventInstance->nativeEvent->target);
    return JS_DupValue(ctx, instance->instanceObject);
  }
  return JS_NULL;
}
PROP_SETTER(Event, target)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, srcElement)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  if (eventInstance->nativeEvent->target != nullptr) {
    auto instance = reinterpret_cast<EventTargetInstance *>(eventInstance->nativeEvent->target);
    return JS_DupValue(ctx, instance->instanceObject);
  }
  return JS_NULL;
}
PROP_SETTER(Event, srcElement)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, currentTarget)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  if (eventInstance->nativeEvent->currentTarget != nullptr) {
    auto instance = reinterpret_cast<EventTargetInstance *>(eventInstance->nativeEvent->currentTarget);
    return JS_DupValue(ctx, instance->instanceObject);
  }
  return JS_NULL;
}
PROP_SETTER(Event, currentTarget)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, returnValue)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, !eventInstance->cancelled());
}
PROP_SETTER(Event, returnValue)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(Event, cancelBubble)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->cancelled());
}
PROP_SETTER(Event, cancelBubble)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
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
    eventInstance = EventInstance::fromNativeEvent(Event::instance(context), static_cast<NativeEvent *>(nativeEvent));
  }

  JS_SetPrototype(context->ctx(), eventInstance->instanceObject, Event::instance(context)->m_prototypeObject);

  return eventInstance;
}

JSValue Event::stopPropagation(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *event = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  event->m_propagationStopped = true;
  return JS_NULL;
}

JSValue Event::stopImmediatePropagation(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *event = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  event->m_propagationStopped = true;
  event->m_propagationImmediatelyStopped = true;
  return JS_NULL;
}

JSValue Event::preventDefault(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *event = static_cast<EventInstance *>(JS_GetOpaque(this_val, Event::kEventClassID));
  if (event->nativeEvent->cancelable) {
    event->m_cancelled = true;
  }
  return JS_NULL;
}

EventInstance * EventInstance::fromNativeEvent(Event *event, NativeEvent *nativeEvent) {
  return new EventInstance(event, nativeEvent);
}

EventInstance::EventInstance(Event *event, NativeEvent *nativeEvent)
  : nativeEvent(nativeEvent), Instance(event, "Event", nullptr, Event::kEventClassID, finalizer) {}
EventInstance::EventInstance(Event *jsEvent, JSAtom eventType, JSValue eventInit) : Instance(jsEvent, "Event",
                                                                                                  nullptr,
                                                                                                  Event::kEventClassID,
                                                                                                  finalizer) {
  JSValue v = JS_AtomToValue(m_ctx, eventType);
  nativeEvent = new NativeEvent{
    jsValueToNativeString(m_ctx, v)
  };
  JS_FreeValue(m_ctx, v);

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
  auto *event = static_cast<EventInstance *>(JS_GetOpaque(val, Event::kEventClassID));
  if (event->context()->isValid()) {
    JS_FreeValue(event->m_ctx, event->instanceObject);
  }
  delete event;
}

} // namespace kraken::binding::qjs
