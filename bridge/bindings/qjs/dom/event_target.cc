/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"

#include <utility>
#include "event.h"
#include "kraken_bridge.h"
#include "bindings/qjs/qjs_patch.h"
#include "element.h"
#include "document.h"
#include "bindings/qjs/bom/window.h"

namespace kraken::binding::qjs {

static std::atomic<int32_t> globalEventTargetId{0};

void bindEventTarget(std::unique_ptr<JSContext> &context) {
  auto *constructor = EventTarget::instance(context.get());
  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  JS_SetPrototype(context->ctx(), context->global(), constructor->classObject);
  context->defineGlobalProperty("EventTarget", constructor->classObject);
}

EventTarget::EventTarget(JSContext *context, const char *name) : HostClass(context, name) {
}
EventTarget::EventTarget(JSContext *context) : HostClass(context, "EventTarget") {
}

OBJECT_INSTANCE_IMPL(EventTarget);

JSValue EventTarget::instanceConstructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  if (argc == 1) {
    JSValue jsOnlyEvents = argv[0];

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
  auto eventTarget = new EventTargetInstance(this, EventTarget::classId(), "EventTarget");
  return eventTarget->instanceObject;
}

JSClassID EventTarget::classId() {
  assert_m(false, "classId is not implemented");
  return 0;
}

JSClassID EventTarget::classId(JSValue &value) {
  JSClassID classId = JSValueGetClassId(value);
  if (classId == Element::classId() || Document::classId() || Window::kWindowClassId) {
    return classId;
  }

  assert_m(false, "can not identify value type.");
  return 0;
}

JSValue EventTarget::addEventListener(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: type and listener are required.");
  }

  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JS_GetOpaque(this_val,
                                                                              EventTarget::classId(this_val)));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue eventTypeValue = argv[0];
  JSValue callback = argv[1];

  if (!JS_IsString(eventTypeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: eventName should be an string.");
  }

  if (!JS_IsObject(callback)) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: callback should be an function.");
  }

  if (!JS_IsFunction(ctx, callback)) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: callback should be an function.");
  }

  const char *cEventType = JS_ToCString(ctx, eventTypeValue);
  std::string eventType = std::string(cEventType);

  // Init list.
  if (eventTargetInstance->_eventHandlers.count(eventType) == 0) {
    eventTargetInstance->_eventHandlers[eventType] = std::vector<JSValue>();
  }

  // Dart needs to be notified for the first registration event.
  if (eventTargetInstance->_eventHandlers[eventType].empty() ||
      eventTargetInstance->_propertyEventHandler.count(eventType) > 0) {
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

  std::vector<JSValue> &handlers = eventTargetInstance->_eventHandlers[eventType];
  JSValue newCallback = JS_DupValue(ctx, callback);

  // Create strong reference between callback and eventTargetObject.
  // So gc can mark this object and recycle it.
  std::string privateKey = eventType + "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(callback)));
  JS_DefinePropertyValueStr(ctx, eventTargetInstance->instanceObject, privateKey.c_str(), newCallback, JS_PROP_NORMAL);

  handlers.push_back(newCallback);
  JS_FreeCString(ctx, cEventType);

  return JS_UNDEFINED;
}

JSValue EventTarget::removeEventListener(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: at least type and listener are required.");
  }

  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JS_GetOpaque(this_val,
                                                                              EventTarget::classId(this_val)));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue eventTypeValue = argv[0];
  JSValue callback = argv[1];

  if (!JS_IsString(eventTypeValue)) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: eventName should be an string.");
  }

  if (!JS_IsObject(callback)) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: callback should be an function.");
  }

  if (!JS_IsFunction(ctx, callback)) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: callback should be an function.");
  }

  const char *cEventType = JS_ToCString(ctx, eventTypeValue);
  std::string eventType = std::string(cEventType);
  if (eventTargetInstance->_eventHandlers.count(eventType) == 0) {
    return JS_UNDEFINED;
  }

  std::vector<JSValue> &handlers = eventTargetInstance->_eventHandlers[eventType];
  std::string privateKey = eventType + "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(callback)));
  JSAtom privateKeyAtom = JS_NewAtom(ctx, privateKey.c_str());
  JS_DeleteProperty(ctx, eventTargetInstance->instanceObject, privateKeyAtom, 0);
  JS_FreeAtom(ctx, privateKeyAtom);

  handlers.erase(std::remove_if(handlers.begin(), handlers.end(), [callback](JSValue function) {
    if (JS_VALUE_GET_PTR(function) == JS_VALUE_GET_PTR(callback)) {
      return true;
    }
    return false;
  }), handlers.end());

  if (handlers.empty() && eventTargetInstance->_propertyEventHandler.count(eventType) > 0) {
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

  JS_FreeCString(ctx, cEventType);
  return JS_UNDEFINED;
}

JSValue EventTarget::dispatchEvent(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to dispatchEvent: first arguments should be an event object");
  }

  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JS_GetOpaque(this_val,
                                                                              EventTarget::classId(this_val)));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue eventValue = argv[0];
  auto eventInstance = reinterpret_cast<EventInstance *>(JS_GetOpaque(eventValue,
                                                                      EventTarget::classId(eventValue)));
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
    auto node = reinterpret_cast<NodeInstance *>(event->nativeEvent->currentTarget);
    NodeInstance *parent = node->parentNode;

    if (parent != nullptr) {
      parent->dispatchEvent(event);
    }
  }

  return event->cancelled();
}

bool EventTargetInstance::internalDispatchEvent(EventInstance *eventInstance) {
  std::u16string u16EventType = std::u16string(
    reinterpret_cast<const char16_t *>(eventInstance->nativeEvent->type->string),
    eventInstance->nativeEvent->type->length);
  std::string eventType = toUTF8(u16EventType);
  auto stack = _eventHandlers[eventType];

  // Dispatch event listeners writen by addEventListener
  auto _dispatchEvent = [&eventInstance, this](JSValue &handler) {
    if (eventInstance->propagationImmediatelyStopped()) return;
    // The third params `thisObject` to null equals global object.
    JSValue returnedValue = JS_Call(m_ctx, handler, JS_NULL, 1, &eventInstance->instanceObject);
    m_context->handleException(&returnedValue);
    JS_FreeValue(m_ctx, returnedValue);
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

#if IS_TEST
JSValue EventTarget::__kraken_clear_event_listener(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JS_GetOpaque(this_val,
                                                                              EventTarget::classId(this_val)));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  eventTargetInstance->_eventHandlers.clear();
  return JS_NULL;
}
#endif

EventTargetInstance::EventTargetInstance(EventTarget *eventTarget, JSClassID classId,
                                         JSClassExoticMethods &exoticMethods, std::string name) : Instance(
  eventTarget, name, &exoticMethods, classId,
  finalize) {
  eventTargetId = globalEventTargetId++;
}

EventTargetInstance::EventTargetInstance(EventTarget *eventTarget, JSClassID classId, std::string name) : Instance(
  eventTarget,
  std::move(name),
  nullptr,
  classId,
  finalize) {
  eventTargetId = globalEventTargetId++;
}

EventTargetInstance::EventTargetInstance(EventTarget *eventTarget, JSClassID classId, std::string name, int64_t eventTargetId) : Instance(
  eventTarget,
  std::move(name),
  nullptr,
  classId,
  finalize), eventTargetId(eventTargetId) {
}

JSClassID EventTargetInstance::classId() {
  assert_m(false, "classId is not implemented");
  return 0;
}

EventTargetInstance::~EventTargetInstance() {
  foundation::UICommandBuffer::instance(m_contextId)
    ->addCommand(eventTargetId, UICommand::disposeEventTarget, nullptr, false);
}

JSValue EventTargetInstance::callNativeMethods(const char *method, int32_t argc,
                                               NativeValue *argv) {
  if (nativeEventTarget->callNativeMethods == nullptr) {
    return JS_ThrowTypeError(m_ctx, "Failed to call native dart methods: callNativeMethods not initialized.");
  }

  std::u16string methodString;
  fromUTF8(method, methodString);

  NativeString m{
    reinterpret_cast<const uint16_t *>(methodString.c_str()),
    static_cast<int32_t>(methodString.size())
  };

  NativeValue nativeValue{};
  nativeEventTarget->callNativeMethods(nativeEventTarget, &nativeValue, &m, argc, argv);
  JSValue returnValue = nativeValueToJSValue(m_context, nativeValue);
  return returnValue;
}

void EventTargetInstance::setPropertyHandler(std::string &name, JSValue value) {
  std::string eventType = name.substr(2);

  // We need to remove previous eventHandler when setting new eventHandler with same eventType.
  if (_propertyEventHandler.count(eventType) > 0) {
    JSValue callback = _propertyEventHandler[eventType];
    std::string privateKey = eventType + "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(callback)));
    JSAtom privateKeyAtom = JS_NewAtom(m_ctx, privateKey.c_str());
    JS_DeleteProperty(m_ctx, instanceObject, privateKeyAtom, 0);
    JS_FreeAtom(m_ctx, privateKeyAtom);
    _propertyEventHandler.erase(eventType);
  }

  // When evaluate scripts like 'element.onclick = null', we needs to remove the event handlers callbacks
  if (JS_IsNull(value)) {
    return;
  }

  // Create strong reference between callback and eventTargetObject.
  // So gc can mark this object and recycle it.
  JSValue newCallback = JS_DupValue(m_ctx, value);
  std::string privateKey = eventType + "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(newCallback)));
  JS_DefinePropertyValueStr(m_ctx, instanceObject, privateKey.c_str(), newCallback, JS_PROP_NORMAL);

  _propertyEventHandler[eventType] = newCallback;

  auto Event = reinterpret_cast<EventTarget *>(prototype());
  auto isJsOnlyEvent = std::find(Event->m_jsOnlyEvents.begin(), Event->m_jsOnlyEvents.end(), name.substr(2)) !=
                       Event->m_jsOnlyEvents.end();

  if (isJsOnlyEvent) return;

  if (_eventHandlers.empty()) {
    int32_t contextId = m_context->getContextId();
    NativeString *args_01 = stringToNativeString(eventType);
    int32_t type = JS_IsFunction(m_ctx, value) ? UICommand::addEvent : UICommand::removeEvent;
    foundation::UICommandBuffer::instance(contextId)->addCommand(eventTargetId, type, *args_01, nullptr);
  }
}

JSValue EventTargetInstance::getPropertyHandler(std::string &name) {
  std::string eventType = name.substr(2);

  if (_propertyEventHandler.count(eventType) == 0) {
    return JS_NULL;
  }
  return JS_DupValue(m_ctx, _propertyEventHandler[eventType]);
}

void EventTargetInstance::finalize(JSRuntime *rt, JSValue val) {
  auto *eventTarget = static_cast<EventTargetInstance *>(JS_GetOpaque(val, EventTarget::classId(val)));
  if (eventTarget->context()->isValid()) {
    JS_FreeValue(eventTarget->m_ctx, eventTarget->instanceObject);
  }
  delete eventTarget;
}

void NativeEventTarget::dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeString *nativeEventType,
                                          void *rawEvent, int32_t isCustomEvent) {
  assert_m(nativeEventTarget->instance != nullptr, "NativeEventTarget should have owner");
  EventTargetInstance *eventTargetInstance = nativeEventTarget->instance;
  JSContext *context = eventTargetInstance->context();
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t *>(nativeEventType->string),
                                               nativeEventType->length);
  std::string eventType = toUTF8(u16EventType);
  auto *raw = static_cast<RawEvent *>(rawEvent);
  // NativeEvent members are memory aligned corresponding to NativeEvent.
  // So we can reinterpret_cast raw bytes pointer to NativeEvent type directly.
  auto *nativeEvent = reinterpret_cast<NativeEvent *>(raw->bytes);
  EventInstance *eventInstance = Event::buildEventInstance(eventType, context, nativeEvent, isCustomEvent == 1);
  eventInstance->nativeEvent->target = eventTargetInstance;
  eventTargetInstance->dispatchEvent(eventInstance);
  JS_FreeValue(context->ctx(), eventInstance->instanceObject);
}

} // namespace kraken::binding::qjs
