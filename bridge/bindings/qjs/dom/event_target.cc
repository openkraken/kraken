/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"
#include "event.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

static std::atomic<int64_t> globalEventTargetId{0};

JSValue EventTarget::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  if (argc == 1) {
    JSValue &jsOnlyEvents = argv[0];

    if (!JS_IsArray(ctx, jsOnlyEvents)) {
      return JS_ThrowTypeError(ctx, "Failed to new Event: jsOnlyEvents is not an array.");
    }

    JSValue lengthValue = JS_GetPropertyStr(ctx, jsOnlyEvents, "length");
    uint32_t length;
    JS_ToUint32(ctx, &length, lengthValue);

    for (size_t i = 0; i < length; i++) {
      JSValue jsOnlyEvent = JS_GetPropertyUint32(ctx, jsOnlyEvents, i);
      const char *event = JS_ToCString(ctx, jsOnlyEvent);
      m_jsOnlyEvents.emplace_back(event);
      JS_FreeValue(ctx, jsOnlyEvent);
    }

    JS_FreeValue(ctx, lengthValue);
  }
  auto eventTarget = new EventTargetInstance(this);
  return eventTarget->instanceObject;
}

JSValue EventTarget::addEventListener(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: type and listener are required.");
  }

  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JS_GetOpaque(this_val, JSContext::kHostClassInstanceClassId));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue &eventTypeValue = argv[0];
  JSValue &callback = argv[1];

  if (!JS_IsString(eventTypeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: eventName should be an string.");
  }

  if (!JS_IsObject(callback)) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: callback should be an function.");
  }

  if (!JS_IsFunction(ctx, callback)) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: callback should be an function.");
  }

  std::string eventType = JS_ToCString(ctx, eventTypeValue);

  // Init list.
  if (eventTargetInstance->_eventHandlers.count(eventType) == 0) {
    eventTargetInstance->_eventHandlers[eventType] = std::forward_list<JSValue>();
  }

  JSValue &propertyHandlers = eventTargetInstance->_propertyEventHandler[eventType];

  // Dart needs to be notified for the first registration event.
  if (eventTargetInstance->_eventHandlers[eventType].empty() || JS_IsFunction(ctx, propertyHandlers)) {
    int32_t contextId = eventTargetInstance->prototype()->contextId();

    NativeString args_01{};
    buildUICommandArgs(ctx, eventTypeValue, args_01);

    auto constructor = reinterpret_cast<EventTarget *>(eventTargetInstance->prototype());
    auto isJsOnlyEvent = std::find(constructor->m_jsOnlyEvents.begin(), constructor->m_jsOnlyEvents.end(), eventType) !=
                         constructor->m_jsOnlyEvents.end();

    if (!isJsOnlyEvent) {
      foundation::UICommandBuffer::instance(contextId)->addCommand(eventTargetInstance->eventTargetId,
                                                                   UICommand::addEvent, args_01, nullptr);
    }
  }

  std::forward_list<JSValue> &handlers = eventTargetInstance->_eventHandlers[eventType];
  handlers.emplace_after(handlers.cbefore_begin(), JS_DupValue(ctx, callback));

  return JS_UNDEFINED;
}

JSValue EventTarget::removeEventListener(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: at least type and listener are required.");
  }

  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JS_GetOpaque(this_val, JSContext::kHostClassInstanceClassId));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue &eventTypeValue = argv[0];
  JSValue &callback = argv[1];

  if (!JS_IsString(eventTypeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: eventName should be an string.");
  }

  if (!JS_IsObject(callback)) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: callback should be an function.");
  }

  if (!JS_IsFunction(ctx, callback)) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: callback should be an function.");
  }

  std::string eventType = JS_ToCString(ctx, eventTypeValue);
  if (eventTargetInstance->_eventHandlers.count(eventType) == 0) {
    return JS_UNDEFINED;
  }

  std::forward_list<JSValue> &handlers = eventTargetInstance->_eventHandlers[eventType];
  handlers.remove_if([&callback, &ctx](JSValue function) {
    if (JS_VALUE_GET_PTR(function) == JS_VALUE_GET_PTR(callback)) {
      JS_FreeValue(ctx, function);
      return true;
    }
    return false;
  });

  JSValue &propertyHandler = eventTargetInstance->_propertyEventHandler[eventType];
  if (handlers.empty() && JS_IsFunction(ctx, propertyHandler)) {
    // Dart needs to be notified for handles is empty.
    int32_t contextId = eventTargetInstance->prototype()->contextId();

    NativeString args_01{};
    buildUICommandArgs(ctx, eventTypeValue, args_01);

    auto constructor = reinterpret_cast<EventTarget *>(eventTargetInstance->prototype());
    auto isJsOnlyEvent = std::find(constructor->m_jsOnlyEvents.begin(), constructor->m_jsOnlyEvents.end(), eventType) !=
        constructor->m_jsOnlyEvents.end();

    if (!isJsOnlyEvent) {
      foundation::UICommandBuffer::instance(contextId)->addCommand(eventTargetInstance->eventTargetId,
                                                                   UICommand::removeEvent, args_01, nullptr);
    }
  }
  return JS_UNDEFINED;
}

JSValue EventTarget::dispatchEvent(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to dispatchEvent: first arguments should be an event object");
  }

  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JS_GetOpaque(this_val, JSContext::kHostClassInstanceClassId));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue &eventValue = argv[0];
  auto eventInstance = reinterpret_cast<EventInstance *>(JS_GetOpaque(eventValue, JSContext::kHostClassInstanceClassId));
  return JS_NewBool(ctx, eventTargetInstance->dispatchEvent(eventInstance));
}

bool EventTargetInstance::dispatchEvent(EventInstance *event) {
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t *>(event->nativeEvent->type->string),
                                               event->nativeEvent->type->length);
  std::string eventType = toUTF8(u16EventType);

  // Modify the currentTarget to this.
  event->nativeEvent->currentTarget = this;

  internalDispatchEvent(event);

  // Bubble event to root event target.
  if (event->nativeEvent->bubbles == 1 && !event->propagationStopped()) {
//    auto node = reinterpret_cast<NodeInstance *>(event->nativeEvent->currentTarget);
//    NodeInstance* parent = node->parentNode;
//
//    if (parent != nullptr) {
//      parent->dispatchEvent(event);
//    }
  }

  return event->cancelled();
}

bool EventTargetInstance::internalDispatchEvent(EventInstance *eventInstance) {
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t *>(eventInstance->nativeEvent->type->string),
                                               eventInstance->nativeEvent->type->length);
  std::string eventType = toUTF8(u16EventType);
  auto stack = _eventHandlers[eventType];

  // Dispatch event listeners writen by addEventListener
  auto _dispatchEvent = [&eventInstance, this](JSValue& handler) {
    if (eventInstance->propagationImmediatelyStopped()) return;

    JSValue arguments[] = { eventInstance->instanceObject };
    // The third params `thisObject` to null equals global object.
    JSValue returnedValue = JS_Call(m_ctx, handler, JS_NULL, 1, arguments);
    m_context->handleException(&returnedValue);
  };

  for (auto &handler : stack) {
    _dispatchEvent(handler);
  }

  // Dispatch event listener white by 'on' prefix property.
  if (_propertyEventHandler.count(eventType) > 0) {
    _dispatchEvent(_propertyEventHandler[eventType]);
  }

  // do not dispatch event when event has been canceled
  // true is prevented.
  return eventInstance->cancelled();
}

JSValue EventTarget::__kraken_clear_event_listener(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JS_GetOpaque(this_val, JSContext::kHostClassInstanceClassId));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }
  for (auto &it : eventTargetInstance->_eventHandlers) {
    for (auto &handler : it.second) {
      JS_FreeValue(eventTargetInstance->m_ctx, handler);
    }
  }

  eventTargetInstance->_eventHandlers.clear();
  return JS_NULL;
}

EventTargetInstance::EventTargetInstance(EventTarget *eventTarget) : Instance(eventTarget, "EventTarget") {
  eventTargetId = globalEventTargetId;
  globalEventTargetId++;
}

JSValue EventTargetInstance::callNativeMethods(const char* method, int32_t argc,
                                                   NativeValue *argv) {
  if (nativeEventTarget.callNativeMethods == nullptr) {
    return JS_ThrowTypeError(m_ctx, "Failed to call native dart methods: callNativeMethods not initialized.");
  }

  std::u16string methodString;
  fromUTF8(method, methodString);

  NativeString m{
      reinterpret_cast<const uint16_t *>(methodString.c_str()),
      static_cast<int32_t>(methodString.size())
  };

  NativeValue nativeValue{};
  nativeEventTarget.callNativeMethods(&nativeEventTarget, &nativeValue, &m, argc, argv);
  JSValue returnValue = nativeValueToJSValue(m_context, nativeValue);
  return returnValue;
}

void bindEventTarget(std::unique_ptr<JSContext> &context) {
  auto *eventTargetConstructor = new EventTarget(context.get());
  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  JS_SetPrototype(context->ctx(), context->global(), eventTargetConstructor->prototype());
  context->defineGlobalProperty("EventTarget", eventTargetConstructor->classObject);
}

void NativeEventTarget::dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeString *nativeEventType,
                                          void *nativeEvent, int32_t isCustomEvent) {
  assert_m(nativeEventTarget->instance != nullptr, "NativeEventTarget should have owner");
  EventTargetInstance *eventTargetInstance = nativeEventTarget->instance;
  JSContext *context = eventTargetInstance->context();
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t *>(nativeEventType->string),
                                               nativeEventType->length);
  std::string eventType = toUTF8(u16EventType);
  EventInstance *eventInstance = Event::buildEventInstance(eventType, context, nativeEvent, isCustomEvent == 1);
  eventInstance->nativeEvent->target = eventTargetInstance;
  eventTargetInstance->dispatchEvent(eventInstance);
}

} // namespace kraken::binding::qjs
