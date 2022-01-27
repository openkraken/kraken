/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "bindings/qjs/qjs_patch.h"
#include "custom_event.h"
#include "event_target.h"

namespace kraken {

void bindEvent(std::unique_ptr<ExecutionContext>& context) {
  JSValue constructor = Event::constructor(context.get());
  JSValue prototype = Event::prototype(context.get());

  // Install readonly properties.
  INSTALL_READONLY_PROPERTY(Event, prototype, type);
  INSTALL_READONLY_PROPERTY(Event, prototype, bubbles);
  INSTALL_READONLY_PROPERTY(Event, prototype, cancelable);
  INSTALL_READONLY_PROPERTY(Event, prototype, timestamp);
  INSTALL_READONLY_PROPERTY(Event, prototype, bubbles);
  INSTALL_READONLY_PROPERTY(Event, prototype, defaultPrevented);
  INSTALL_READONLY_PROPERTY(Event, prototype, target);
  INSTALL_READONLY_PROPERTY(Event, prototype, srcElement);
  INSTALL_READONLY_PROPERTY(Event, prototype, currentTarget);
  INSTALL_READONLY_PROPERTY(Event, prototype, returnValue);
  INSTALL_READONLY_PROPERTY(Event, prototype, cancelBubble);

  // Install functions
  INSTALL_FUNCTION(Event, prototype, stopPropagation, 0);
  INSTALL_FUNCTION(Event, prototype, stopImmediatePropagation, 0);
  INSTALL_FUNCTION(Event, prototype, preventDefault, 1);
  INSTALL_FUNCTION(Event, prototype, initEvent, 3);

  context->defineGlobalProperty("Event", constructor);
}

JSClassID Event::classId{0};

Event* Event::create(JSContext* ctx) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue prototype = context->contextData()->prototypeForType(&eventTypeInfo);

  auto* event = makeGarbageCollected<Event>()->initialize<Event>(ctx, &classId);

  // Let eventTarget instance inherit EventTarget prototype methods.
  JS_SetPrototype(ctx, event->toQuickJS(), prototype);

  return event;
}

Event* Event::create(JSContext* ctx, NativeEvent* nativeEvent) {
  auto* event = create(ctx);
  event->nativeEvent = nativeEvent;
  return event;
}

Event::Event(NativeEvent* nativeEvent) : nativeEvent(nativeEvent) {}
Event::Event(JSValue eventType, JSValue eventInit) {}

JSValue Event::constructor(ExecutionContext* context) {
  return context->contextData()->constructorForType(&eventTypeInfo);
}

JSValue Event::prototype(ExecutionContext* context) {
  return context->contextData()->prototypeForType(&eventTypeInfo);
}

std::unordered_map<std::string, EventCreator> Event::m_eventCreatorMap{};

IMPL_PROPERTY_GETTER(Event, type)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* eventInstance = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  return JS_NewUnicodeString(eventInstance->context()->runtime(), eventInstance->context()->ctx(), eventInstance->nativeEvent->type->string, eventInstance->nativeEvent->type->length);
}

IMPL_PROPERTY_GETTER(Event, bubbles)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  return JS_NewBool(ctx, event->nativeEvent->bubbles);
}

IMPL_PROPERTY_GETTER(Event, cancelable)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  return JS_NewBool(ctx, event->nativeEvent->cancelable);
}

IMPL_PROPERTY_GETTER(Event, timestamp)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  return JS_NewInt64(ctx, event->nativeEvent->timeStamp);
}

IMPL_PROPERTY_GETTER(Event, defaultPrevented)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  return JS_NewBool(ctx, event->cancelled());
}

IMPL_PROPERTY_GETTER(Event, target)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  if (event->nativeEvent->target != nullptr) {
    auto eventTarget = reinterpret_cast<EventTarget*>(event->nativeEvent->target);
    return JS_DupValue(ctx, eventTarget->toQuickJS());
  }
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Event, srcElement)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  if (event->nativeEvent->target != nullptr) {
    auto eventTarget = reinterpret_cast<EventTarget*>(event->nativeEvent->target);
    return JS_DupValue(ctx, eventTarget->toQuickJS());
  }
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Event, currentTarget)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  if (event->nativeEvent->currentTarget != nullptr) {
    auto eventTarget = reinterpret_cast<EventTarget*>(event->nativeEvent->currentTarget);
    return JS_DupValue(ctx, eventTarget->toQuickJS());
  }
  return JS_NULL;
}

IMPL_PROPERTY_GETTER(Event, returnValue)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  return JS_NewBool(ctx, !event->cancelled());
}

IMPL_PROPERTY_GETTER(Event, cancelBubble)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  return JS_NewBool(ctx, event->cancelled());
}

// Event* Event::buildEvent(JSValue eventType, JSContext* ctx, void* nativeEvent, bool isCustomEvent) {
//  Event* event;
//  if (isCustomEvent) {
//    event = CustomEvent::create(ctx, reinterpret_cast<NativeCustomEvent*>(nativeEvent), eventType);
//  } else if (m_eventCreatorMap.count(eventType) > 0) {
//    event = m_eventCreatorMap[eventType](ctx, nativeEvent);
//  } else {
//    event = Event::create(ctx, static_cast<NativeEvent*>(nativeEvent));
//  }
//  return event;
//}

void Event::defineEvent(const std::string& eventType, EventCreator creator) {
  m_eventCreatorMap[eventType] = creator;
}

IMPL_FUNCTION(Event, stopPropagation)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  event->m_propagationStopped = true;
  return JS_NULL;
}

IMPL_FUNCTION(Event, stopImmediatePropagation)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  event->m_propagationStopped = true;
  event->m_propagationImmediatelyStopped = true;
  return JS_NULL;
}

IMPL_FUNCTION(Event, preventDefault)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  if (event->nativeEvent->cancelable) {
    event->m_cancelled = true;
  }
  return JS_NULL;
}

IMPL_FUNCTION(Event, initEvent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
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

  auto* event = static_cast<Event*>(JS_GetOpaque(this_val, Event::classId));
  event->nativeEvent->type = jsValueToNativeString(ctx, typeValue).release();

  if (!JS_IsNull(bubblesValue)) {
    event->nativeEvent->bubbles = JS_IsBool(bubblesValue) ? 1 : 0;
  }
  if (!JS_IsNull(cancelableValue)) {
    event->nativeEvent->cancelable = JS_IsBool(cancelableValue) ? 1 : 0;
  }
  return JS_NULL;
}

void Event::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {}

void Event::dispose() const {
  delete nativeEvent;
}

}  // namespace kraken
