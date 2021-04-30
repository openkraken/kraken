/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#include "event_target.h"
#include "dart_methods.h"
#include "document.h"
#include "event.h"
#include <codecvt>

namespace kraken::binding::jsc {

static std::atomic<int64_t> globalEventTargetId{0};

void bindEventTarget(std::unique_ptr<JSContext> &context) {
  auto eventTarget = JSEventTarget::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "EventTarget", eventTarget->classObject);
}

std::unordered_map<JSContext *, JSEventTarget *> JSEventTarget::instanceMap{};

JSEventTarget *JSEventTarget::instance(JSContext *context) {
  if (instanceMap.count(context) == 0) {
    instanceMap[context] = new JSEventTarget(context, nullptr, nullptr);
  }
  return instanceMap[context];
}

JSEventTarget::~JSEventTarget() {
  instanceMap.erase(context);
}

JSEventTarget::JSEventTarget(JSContext *context, const char *name) : HostClass(context, name) {}
JSEventTarget::JSEventTarget(JSContext *context, const JSStaticFunction *staticFunction,
                             const JSStaticValue *staticValue)
  : HostClass(context, nullptr, "EventTarget", staticFunction, staticValue) {}

JSObjectRef JSEventTarget::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount == 1) {
    const JSValueRef jsOnlyEventsValueRef = arguments[0];

    if (!JSValueIsArray(ctx, jsOnlyEventsValueRef)) {
      throwJSError(ctx, "Failed to new Event: jsOnlyEvents is not an array.", exception);
      return nullptr;
    }

    JSObjectRef jsOnlyEvents = JSValueToObject(ctx, jsOnlyEventsValueRef, exception);
    JSStringRef lengthStr = JSStringCreateWithUTF8CString("length");
    JSValueRef lengthValue = JSObjectGetProperty(ctx, jsOnlyEvents, lengthStr, exception);
    size_t length = JSValueToNumber(ctx, lengthValue, exception);

    for (size_t i = 0; i < length; i++) {
      JSValueRef jsOnlyEvent = JSObjectGetPropertyAtIndex(ctx, jsOnlyEvents, i, exception);
      JSStringRef e = JSValueToStringCopy(ctx, jsOnlyEvent, exception);
      std::string event = JSStringToStdString(e);
      m_jsOnlyEvents.emplace_back(event);
    }
  }

  auto eventTarget = new EventTargetInstance(this);
  setProto(ctx, eventTarget->object, constructor, exception);
  return constructor;
}

EventTargetInstance::EventTargetInstance(JSEventTarget *eventTarget) : Instance(eventTarget) {
  eventTargetId = globalEventTargetId;
  globalEventTargetId++;
  nativeEventTarget = new NativeEventTarget(this);
}

EventTargetInstance::EventTargetInstance(JSEventTarget *eventTarget, int64_t id)
  : Instance(eventTarget), eventTargetId(id) {
  nativeEventTarget = new NativeEventTarget(this);
}

EventTargetInstance::~EventTargetInstance() {
  // Recycle eventTarget object could be triggered by hosting JSContext been released or reference count set to 0.
  foundation::UICommandTaskMessageQueue::instance(_hostClass->contextId)
      ->registerCommand(eventTargetId, UICommand::disposeEventTarget, nullptr, false);

  // Release handler callbacks.
  if (context->isValid()) {
    for (auto &it : _eventHandlers) {
      for (auto &handler : it.second) {
        JSValueUnprotect(_hostClass->ctx, handler);
      }
    }
  }

  foundation::UICommandCallbackQueue::instance()->registerCallback([](void *ptr) {
    delete reinterpret_cast<NativeEventTarget *>(ptr);
  }, nativeEventTarget);
}

JSValueRef JSEventTarget::addEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount < 2) {
    throwJSError(ctx, "Failed to addEventListener: eventName and function parameter are required.", exception);
    return nullptr;
  }

  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JSObjectGetPrivate(thisObject));
  if (eventTargetInstance == nullptr) {
    JSObjectRef prototypeObject = getProto(ctx, thisObject, exception);
    eventTargetInstance = static_cast<EventTargetInstance *>(JSObjectGetPrivate(prototypeObject));
  }

  assert_m(eventTargetInstance != nullptr, "this object is not a instance of eventTarget.");

  const JSValueRef eventNameValueRef = arguments[0];
  const JSValueRef callback = arguments[1];

  if (!JSValueIsString(ctx, eventNameValueRef)) {
    throwJSError(ctx, "Failed to addEventListener: eventName should be an string.", exception);
    return nullptr;
  }

  if (!JSValueIsObject(ctx, callback)) {
    throwJSError(ctx, "Failed to addEventListener: callback should be an function.", exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callback, exception);
  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    throwJSError(ctx, "Failed to addEventListener: callback should be an function.", exception);
    return nullptr;
  }

  JSStringRef eventTypeStringRef = JSValueToStringCopy(ctx, eventNameValueRef, exception);
  std::string &&eventType = JSStringToStdString(eventTypeStringRef);

  // this is an bargain optimize for addEventListener which send `addEvent` message to kraken Dart side only once and
  // no one can stop element to trigger event from dart side. this can led to significant performance improvement when
  // using Front-End frameworks such as Rax, or cause some overhead performance issue when some event trigger more
  // frequently.
  if (eventTargetInstance->_eventHandlers.count(eventType) == 0 ||
      eventTargetInstance->eventTargetId == BODY_TARGET_ID) {
    eventTargetInstance->_eventHandlers[eventType] = std::deque<JSObjectRef>();
    int32_t contextId = eventTargetInstance->_hostClass->contextId;

    NativeString args_01{};
    buildUICommandArgs(eventType, args_01);

    auto EventTarget = reinterpret_cast<JSEventTarget *>(eventTargetInstance->_hostClass);
    auto isJsOnlyEvent =
      std::find(EventTarget->m_jsOnlyEvents.begin(), EventTarget->m_jsOnlyEvents.end(), eventType) != EventTarget->m_jsOnlyEvents.end();

    if (!isJsOnlyEvent) {
      foundation::UICommandTaskMessageQueue::instance(contextId)->registerCommand(
        eventTargetInstance->eventTargetId, UICommand::addEvent, args_01, nullptr);
    };
  }
  std::deque<JSObjectRef> &handlers = eventTargetInstance->_eventHandlers[eventType];
  JSValueProtect(ctx, callbackObjectRef);
  handlers.emplace_back(callbackObjectRef);

  return nullptr;
}

JSValueRef JSEventTarget::prototypeGetProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getEventTargetPropertyMap();

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    default:
      break;
    }
  }

  return HostClass::prototypeGetProperty(name, exception);
}

JSValueRef JSEventTarget::removeEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                              size_t argumentCount, const JSValueRef *arguments,
                                              JSValueRef *exception) {
  if (argumentCount != 2) {
    throwJSError(ctx, "Failed to removeEventListener: eventName and function parameter are required.", exception);
    return nullptr;
  }

  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JSObjectGetPrivate(thisObject));
  if (eventTargetInstance == nullptr) {
    JSObjectRef prototypeObject = getProto(ctx, thisObject, exception);
    eventTargetInstance = static_cast<EventTargetInstance *>(JSObjectGetPrivate(prototypeObject));
  }
  assert_m(eventTargetInstance != nullptr, "this object is not a instance of eventTarget.");

  const JSValueRef eventNameValueRef = arguments[0];
  const JSValueRef callback = arguments[1];

  if (!JSValueIsString(ctx, eventNameValueRef)) {
    throwJSError(ctx, "Failed to removeEventListener: eventName should be an string.", exception);
    return nullptr;
  }

  if (!JSValueIsObject(ctx, callback)) {
    throwJSError(ctx, "Failed to removeEventListener: callback should be an function.", exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callback, exception);
  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    throwJSError(ctx, "Failed to removeEventListener: callback should be an function.", exception);
    return nullptr;
  }

  JSStringRef eventNameStringRef = JSValueToStringCopy(ctx, eventNameValueRef, exception);
  std::string &&eventType = JSStringToStdString(eventNameStringRef);

  if (eventTargetInstance->_eventHandlers.count(eventType) == 0) {
    return nullptr;
  }

  std::deque<JSObjectRef> &handlers = eventTargetInstance->_eventHandlers[eventType];

  for (auto it = handlers.begin(); it != handlers.end();) {
    if (*it == callbackObjectRef) {
      JSValueUnprotect(ctx, callbackObjectRef);
      it = handlers.erase(it);
    } else {
      ++it;
    }
  }

  return nullptr;
}

JSValueRef JSEventTarget::dispatchEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    throwJSError(ctx, "Failed to dispatchEvent: first arguments should be an event object", exception);
    return nullptr;
  }

  auto *eventTargetInstance = static_cast<EventTargetInstance *>(JSObjectGetPrivate(thisObject));
  if (eventTargetInstance == nullptr) {
    JSObjectRef prototypeObject = getProto(ctx, thisObject, exception);
    eventTargetInstance = static_cast<EventTargetInstance *>(JSObjectGetPrivate(prototypeObject));
  }
  assert_m(eventTargetInstance != nullptr, "this object is not a instance of eventTarget.");

  const JSValueRef eventObjectValueRef = arguments[0];
  JSObjectRef eventObjectRef = JSValueToObject(ctx, eventObjectValueRef, exception);
  auto eventInstance = reinterpret_cast<EventInstance *>(JSObjectGetPrivate(eventObjectRef));

  return JSValueMakeBoolean(ctx, eventTargetInstance->dispatchEvent(eventInstance));
}

bool EventTargetInstance::dispatchEvent(EventInstance *event) {
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t *>(event->nativeEvent->type->string),
                                            event->nativeEvent->type->length);
  std::string eventType = toUTF8(u16EventType);

  if (_eventHandlers.count(eventType) == 0) {
    return false;
  }

  event->nativeEvent->target = event->nativeEvent->currentTarget = this;

  // event has been dispatched, then do not dispatch
  event->_dispatchFlag = true;
  bool cancelled = internalDispatchEvent(event);

  if (event->nativeEvent->bubbles == 1 && !cancelled && !event->_stopPropagationFlag) {
    auto node = reinterpret_cast<NodeInstance *>(event->nativeEvent->currentTarget);
    event->nativeEvent->currentTarget = node->parentNode;

    auto parent = reinterpret_cast<NodeInstance *>(event->nativeEvent->currentTarget);
    if (parent != nullptr) {
      parent->dispatchEvent(event);
    }
  }

  event->_dispatchFlag = false;
  return event->_canceledFlag;
}

JSValueRef JSEventTarget::clearListeners(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                         size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto eventTargetInstance = static_cast<EventTargetInstance *>(JSObjectGetPrivate(thisObject));
  assert_m(eventTargetInstance != nullptr, "this object is not a instance of eventTarget.");

  for (auto &it : eventTargetInstance->_eventHandlers) {
    for (auto &handler : it.second) {
      JSValueUnprotect(eventTargetInstance->_hostClass->ctx, handler);
    }
  }

  eventTargetInstance->_eventHandlers.clear();
  return nullptr;
}

JSValueRef EventTargetInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = JSEventTarget::getEventTargetPropertyMap();
  auto prototypePropertyMap = JSEventTarget::getEventTargetPrototypePropertyMap();

  if (prototypePropertyMap.count(name) > 0) {
    JSStringHolder nameStringHolder = JSStringHolder(context, name);
    return JSObjectGetProperty(ctx, prototype<JSEventTarget>()->prototypeObject, nameStringHolder.getString(), exception);
  }

  if (propertyMap.count(name) > 0) {
    auto property = propertyMap[name];

    switch (property) {
    case JSEventTarget::EventTargetProperty::eventTargetId: {
      return JSValueMakeNumber(_hostClass->ctx, eventTargetId);
    }
    }
  } else if (name.substr(0, 2) == "on") {
    return getPropertyHandler(name, exception);
  }

  return Instance::getProperty(name, exception);
}

bool EventTargetInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  auto staticPropertyMap = JSEventTarget::getEventTargetPrototypePropertyMap();

  if (staticPropertyMap.count(name) > 0) return false;

  if (name.substr(0, 2) == "on") {
    setPropertyHandler(name, value, exception);
    return true;
  } else {
    return Instance::setProperty(name, value, exception);
  }
}

JSValueRef EventTargetInstance::getPropertyHandler(std::string &name, JSValueRef *exception) {
  std::string eventType = name.substr(2);

  if (_eventHandlers.count(eventType) == 0) {
    return JSValueMakeNull(ctx);
  }
  return _eventHandlers[eventType].front();
}

void EventTargetInstance::setPropertyHandler(std::string &name, JSValueRef value,
                                                            JSValueRef *exception) {
  std::string eventType = name.substr(2);

  if (_eventHandlers.count(eventType) == 0) {
    _eventHandlers[eventType] = std::deque<JSObjectRef>();
  }

  JSObjectRef handlerObjectRef = JSValueToObject(_hostClass->ctx, value, exception);
  JSValueProtect(_hostClass->ctx, handlerObjectRef);
  _eventHandlers[eventType].emplace_back(handlerObjectRef);

  auto Event = reinterpret_cast<JSEventTarget *>(_hostClass);
  auto isJsOnlyEvent = std::find(Event->m_jsOnlyEvents.begin(), Event->m_jsOnlyEvents.end(), name.substr(2)) !=
                       Event->m_jsOnlyEvents.end();

  if (isJsOnlyEvent) return;

  int32_t contextId = _hostClass->contextId;
  NativeString args_01{};
  buildUICommandArgs(eventType, args_01);
  foundation::UICommandTaskMessageQueue::instance(contextId)->registerCommand(eventTargetId, UICommand::addEvent, args_01, nullptr);
}

void EventTargetInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &propertyName : JSEventTarget::getEventTargetPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, propertyName);
  }

  for (auto &propertyName : JSEventTarget::getEventTargetPrototypePropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, propertyName);
  }
}

bool EventTargetInstance::internalDispatchEvent(EventInstance *eventInstance) {
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t *>(eventInstance->nativeEvent->type->string),
                                               eventInstance->nativeEvent->type->length);
  std::string eventType = toUTF8(u16EventType);
  auto stack = _eventHandlers[eventType];

  for (auto &handler : stack) {
    if (eventInstance->_stopImmediatePropagationFlag) break;

    JSValueRef exception = nullptr;
    const JSValueRef arguments[] = {eventInstance->object};
    JSObjectCallAsFunction(_hostClass->ctx, handler, handler, 1, arguments, &exception);
    context->handleException(exception);
  }

  // do not dispatch event when event has been canceled
  // true is prevented.
  return eventInstance->_canceledFlag;
}

// This function will be called back by dart side when trigger events.
void NativeEventTarget::dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeString *nativeEventType, void *nativeEvent, int32_t isCustomEvent) {
  assert_m(nativeEventTarget->instance != nullptr, "NativeEventTarget should have owner");
  EventTargetInstance *eventTargetInstance = nativeEventTarget->instance;
  JSContext *context = eventTargetInstance->context;
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t *>(nativeEventType->string),
                                               nativeEventType->length);
  std::string eventType = toUTF8(u16EventType);
  EventInstance *eventInstance = JSEvent::buildEventInstance(eventType, context, nativeEvent, isCustomEvent == 1);
  eventTargetInstance->dispatchEvent(eventInstance);
}

} // namespace kraken::binding::jsc
