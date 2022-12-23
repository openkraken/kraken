/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "event.h"
#include "bindings/qjs/bom/window.h"
#include "bindings/qjs/qjs_patch.h"
#include "custom_event.h"
#include "event_target.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

std::once_flag kEventInitOnceFlag;

void bindEvent(ExecutionContext* context) {
  auto* constructor = Event::instance(context);
  context->defineGlobalProperty("Event", constructor->jsObject);
}

JSClassID Event::kEventClassID{0};

Event::Event(ExecutionContext* context) : HostClass(context, "Event") {
  std::call_once(kEventInitOnceFlag, []() { JS_NewClassID(&kEventClassID); });
}

JSValue Event::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to construct 'Event': 1 argument required, but only 0 present.");
  }

  JSValue eventTypeValue = argv[0];
  std::string eventType = jsValueToStdString(ctx, eventTypeValue);

#if ANDROID_32_BIT
  auto* nativeEvent = new NativeEvent{reinterpret_cast<int64_t>(stringToNativeString(eventType).release())};
#else
  auto* nativeEvent = new NativeEvent{stringToNativeString(eventType).release()};
#endif
  auto* event = Event::buildEventInstance(eventType, m_context, nativeEvent, false);
  return event->jsObject;
}

std::unordered_map<std::string, EventCreator> Event::m_eventCreatorMap{};

IMPL_PROPERTY_GETTER(Event, type)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  auto* pType = reinterpret_cast<NativeString*>(eventInstance->nativeEvent->type);
  return JS_NewUnicodeString(ExecutionContext::runtime(), eventInstance->context()->ctx(), pType->string, pType->length);
}

IMPL_PROPERTY_GETTER(Event, bubbles)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->nativeEvent->bubbles);
}

IMPL_PROPERTY_GETTER(Event, cancelable)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->nativeEvent->cancelable);
}

IMPL_PROPERTY_GETTER(Event, timestamp)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewInt64(ctx, eventInstance->nativeEvent->timeStamp);
}

IMPL_PROPERTY_GETTER(Event, defaultPrevented)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->cancelled());
}

IMPL_PROPERTY_GETTER(Event, target)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));

  if (eventInstance->target() != nullptr) {
    return JS_DupValue(ctx, ensureWindowIsGlobal(eventInstance->target()));
  }
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Event, srcElement)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));

  if (eventInstance->target() != nullptr) {
    return JS_DupValue(ctx, ensureWindowIsGlobal(eventInstance->target()));
  }
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Event, currentTarget)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));

  if (eventInstance->currentTarget() != nullptr) {
    return JS_DupValue(ctx, ensureWindowIsGlobal(eventInstance->currentTarget()));
  }
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Event, returnValue)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, !eventInstance->cancelled());
}

IMPL_PROPERTY_GETTER(Event, cancelBubble)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  return JS_NewBool(ctx, eventInstance->cancelled());
}

EventInstance* Event::buildEventInstance(std::string& eventType, ExecutionContext* context, void* nativeEvent, bool isCustomEvent) {
  EventInstance* eventInstance;
  if (isCustomEvent) {
    eventInstance = new CustomEventInstance(CustomEvent::instance(context), reinterpret_cast<NativeCustomEvent*>(nativeEvent));
  } else if (m_eventCreatorMap.count(eventType) > 0) {
    eventInstance = m_eventCreatorMap[eventType](context, nativeEvent);
  } else {
    eventInstance = EventInstance::fromNativeEvent(Event::instance(context), static_cast<NativeEvent*>(nativeEvent));
  }

  return eventInstance;
}

void Event::defineEvent(const std::string& eventType, EventCreator creator) {
  m_eventCreatorMap[eventType] = creator;
}

JSValue Event::stopPropagation(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  event->m_propagationStopped = true;
  return JS_NULL;
}

JSValue Event::stopImmediatePropagation(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  event->m_propagationStopped = true;
  event->m_propagationImmediatelyStopped = true;
  return JS_NULL;
}

JSValue Event::preventDefault(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  if (event->nativeEvent->cancelable) {
    event->m_cancelled = true;
  }
  return JS_NULL;
}

JSValue Event::initEvent(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to initEvent required, but only 0 present.");
  }

  JSValue typeValue = argv[0];
  JSValue bubblesValue = JS_NULL;
  JSValue cancelableValue = JS_NULL;
  if (argc > 1) {
    bubblesValue = argv[1];
  }

  if (argc > 2) {
    cancelableValue = argv[2];
  }

  if (!JS_IsString(typeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to initEvent: type should be a string.");
  }

  auto* event = static_cast<EventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  event->setType(jsValueToNativeString(ctx, typeValue).release());

  if (!JS_IsNull(bubblesValue)) {
    event->nativeEvent->bubbles = JS_IsBool(bubblesValue) ? 1 : 0;
  }
  if (!JS_IsNull(cancelableValue)) {
    event->nativeEvent->cancelable = JS_IsBool(cancelableValue) ? 1 : 0;
  }
  return JS_NULL;
}

EventInstance* EventInstance::fromNativeEvent(Event* event, NativeEvent* nativeEvent) {
  return new EventInstance(event, nativeEvent);
}

void EventInstance::setType(NativeString* type) const {
#if ANDROID_32_BIT
  nativeEvent->type = reinterpret_cast<int64_t>(type);
#else
  nativeEvent->type = type;
#endif
}

EventTargetInstance* EventInstance::target() const {
  return reinterpret_cast<NativeEventTarget*>(nativeEvent->target)->instance;
}

void EventInstance::setTarget(EventTargetInstance* target) const {
#if ANDROID_32_BIT
  nativeEvent->target = reinterpret_cast<int64_t>(target);
#else
  nativeEvent->target = target->nativeEventTarget;
#endif
}

EventTargetInstance* EventInstance::currentTarget() const {
  return reinterpret_cast<NativeEventTarget*>(nativeEvent->currentTarget)->instance;
}

void EventInstance::setCurrentTarget(EventTargetInstance* currentTarget) const {
#if ANDROID_32_BIT
  nativeEvent->currentTarget = reinterpret_cast<int64_t>(currentTarget);
#else
  nativeEvent->currentTarget = currentTarget->nativeEventTarget;
#endif
}

EventInstance::EventInstance(Event* event, NativeEvent* nativeEvent) : nativeEvent(nativeEvent), Instance(event, "Event", nullptr, Event::kEventClassID, finalizer) {}
EventInstance::EventInstance(Event* jsEvent, JSAtom eventType, JSValue eventInit) : Instance(jsEvent, "Event", nullptr, Event::kEventClassID, finalizer) {
  JSValue v = JS_AtomToValue(m_ctx, eventType);
#if ANDROID_32_BIT
  nativeEvent = new NativeEvent{reinterpret_cast<int64_t>(jsValueToNativeString(m_ctx, v).release())};
#else
  nativeEvent = new NativeEvent{jsValueToNativeString(m_ctx, v).release()};
#endif
  JS_FreeValue(m_ctx, v);

  auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
  nativeEvent->timeStamp = ms.count();

  if (!JS_IsNull(eventInit)) {
    ;
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

void EventInstance::finalizer(JSRuntime* rt, JSValue val) {
  auto* event = static_cast<EventInstance*>(JS_GetOpaque(val, Event::kEventClassID));
  delete event;
}

}  // namespace kraken::binding::qjs
