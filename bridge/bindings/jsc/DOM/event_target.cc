/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"
#include "dart_methods.h"
#include "document.h"
#include "event.h"
#include "bindings/jsc/DOM/events/input_event.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

static std::atomic<int64_t> globalEventTargetId{0};

void bindEventTarget(std::unique_ptr<JSContext> &context) {
  auto eventTarget = JSEventTarget::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "EventTarget", eventTarget->classObject);
}

JSEventTarget *JSEventTarget::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSEventTarget *> instanceMap{};
  if (!instanceMap.contains(context)) {
    const JSStaticFunction staticFunction[]{{"addEventListener", addEventListener, kJSPropertyAttributeReadOnly},
                                            {"removeEventListener", removeEventListener, kJSPropertyAttributeReadOnly},
                                            {"dispatchEvent", dispatchEvent, kJSPropertyAttributeReadOnly},
                                            {"__clearListeners__", clearListeners, kJSPropertyAttributeReadOnly},
                                            {nullptr}};
    instanceMap[context] = new JSEventTarget(context, staticFunction, nullptr);
  }
  return instanceMap[context];
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
      JSC_THROW_ERROR(ctx, "Failed to new Event: jsOnlyEvents is not an array.", exception);
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

  auto eventTarget = new JSEventTarget::EventTargetInstance(this);
  setProto(ctx, eventTarget->object, constructor, exception);
  return constructor;
}

JSEventTarget::EventTargetInstance::EventTargetInstance(JSEventTarget *eventTarget) : Instance(eventTarget) {
  eventTargetId = globalEventTargetId;
  globalEventTargetId++;
  nativeEventTarget = new NativeEventTarget(this);
}

JSEventTarget::EventTargetInstance::EventTargetInstance(JSEventTarget *eventTarget, int64_t id)
  : Instance(eventTarget), eventTargetId(id) {
  nativeEventTarget = new NativeEventTarget(this);
}

JSEventTarget::EventTargetInstance::~EventTargetInstance() {
  // Recycle eventTarget object could be triggered by hosting JSContext been released or reference count set to 0.
  if (context->isValid()) {
    auto data = new DisposeCallbackData(_hostClass->contextId, eventTargetId);
    foundation::Task disposeTask = [](void *data) {
      auto disposeCallbackData = reinterpret_cast<DisposeCallbackData *>(data);
      foundation::UICommandTaskMessageQueue::instance(disposeCallbackData->contextId)
        ->registerCommand(disposeCallbackData->id, UICommand::disposeEventTarget, nullptr, 0, nullptr);
      delete disposeCallbackData;
    };
    foundation::UITaskMessageQueue::instance()->registerTask(disposeTask, data);
  }

  // Release handler callbacks.
  if (context->isValid()) {
    for (auto &it : _eventHandlers) {
      for (auto &handler : it.second) {
        JSValueUnprotect(_hostClass->ctx, handler);
      }
    }
  }

  delete nativeEventTarget;
}

JSValueRef JSEventTarget::addEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount != 2) {
    JSC_THROW_ERROR(ctx, "Failed to addEventListener: eventName and function parameter are required.", exception)
    return nullptr;
  }

  JSEventTarget::EventTargetInstance *eventTargetInstance;

  if (hasProto(ctx, thisObject, exception)) {
    eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(getProto(ctx, thisObject, exception)));
  } else {
    eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(thisObject));
  }

  assert_m(eventTargetInstance != nullptr, "this object is not a instance of eventTarget.");

  const JSValueRef eventNameValueRef = arguments[0];
  const JSValueRef callback = arguments[1];

  if (!JSValueIsString(ctx, eventNameValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to addEventListener: eventName should be an string.", exception);
    return nullptr;
  }

  if (!JSValueIsObject(ctx, callback)) {
    JSC_THROW_ERROR(ctx, "Failed to addEventListener: callback should be an function.", exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callback, exception);
  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    JSC_THROW_ERROR(ctx, "Failed to addEventListener: callback should be an function.", exception);
    return nullptr;
  }

  JSStringRef eventNameStringRef = JSValueToStringCopy(ctx, eventNameValueRef, exception);
  std::string &&eventName = JSStringToStdString(eventNameStringRef);
  JSEvent::EventType eventType = JSEvent::getEventTypeOfName(eventName);

  // this is an bargain optimize for addEventListener which send `addEvent` message to kraken Dart side only once and
  // no one can stop element to trigger event from dart side. this can led to significant performance improvement when
  // using Front-End frameworks such as Rax, or cause some overhead performance issue when some event trigger more
  // frequently.
  if (!eventTargetInstance->_eventHandlers.contains(eventType) ||
      eventTargetInstance->eventTargetId == BODY_TARGET_ID) {
    eventTargetInstance->_eventHandlers[eventType] = std::deque<JSObjectRef>();
    int32_t contextId = eventTargetInstance->_hostClass->contextId;

    std::string eventTypeString = std::to_string(eventType);
    auto args = buildUICommandArgs(eventTypeString);

    auto Event = reinterpret_cast<JSEventTarget*>(eventTargetInstance->_hostClass);
    auto isJsOnlyEvent = std::find(Event->m_jsOnlyEvents.begin(), Event->m_jsOnlyEvents.end(), eventName) != Event->m_jsOnlyEvents.end();

    if (!isJsOnlyEvent) {
      foundation::UICommandTaskMessageQueue::instance(contextId)->registerCommand(eventTargetInstance->eventTargetId, UICommand::addEvent, args, 1, nullptr);
    };
  }

  std::deque<JSObjectRef> &handlers = eventTargetInstance->_eventHandlers[eventType];
  JSValueProtect(ctx, callbackObjectRef);
  handlers.emplace_back(callbackObjectRef);

  return nullptr;
}

JSValueRef JSEventTarget::prototypeGetProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getEventTargetPropertyMap();

  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    switch (property) {
    case EventTargetProperty::kAddEventListener:
      return m_addEventListener.function();
    case EventTargetProperty::kRemoveEventListener:
      return m_removeEventListener.function();
    case EventTargetProperty::kDispatchEvent:
      return m_dispatchEvent.function();
    case EventTargetProperty::kClearListeners:
      return m_clearListeners.function();
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
    JSC_THROW_ERROR(ctx, "Failed to removeEventListener: eventName and function parameter are required.", exception);
    return nullptr;
  }

  JSEventTarget::EventTargetInstance *eventTargetInstance;

  if (hasProto(ctx, thisObject, exception)) {
    eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(getProto(ctx, thisObject, exception)));
  } else {
    eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(thisObject));
  }
  assert_m(eventTargetInstance != nullptr, "this object is not a instance of eventTarget.");

  const JSValueRef eventNameValueRef = arguments[0];
  const JSValueRef callback = arguments[1];

  if (!JSValueIsString(ctx, eventNameValueRef)) {
    JSC_THROW_ERROR(ctx, "Failed to removeEventListener: eventName should be an string.", exception);
    return nullptr;
  }

  if (!JSValueIsObject(ctx, callback)) {
    JSC_THROW_ERROR(ctx, "Failed to removeEventListener: callback should be an function.", exception);
    return nullptr;
  }

  JSObjectRef callbackObjectRef = JSValueToObject(ctx, callback, exception);
  if (!JSObjectIsFunction(ctx, callbackObjectRef)) {
    JSC_THROW_ERROR(ctx, "Failed to removeEventListener: callback should be an function.", exception);
    return nullptr;
  }

  JSStringRef eventNameStringRef = JSValueToStringCopy(ctx, eventNameValueRef, exception);
  std::string &&eventName = JSStringToStdString(eventNameStringRef);
  JSEvent::EventType eventType = JSEvent::getEventTypeOfName(eventName);

  if (!eventTargetInstance->_eventHandlers.contains(eventType)) {
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
    JSC_THROW_ERROR(ctx, "Failed to dispatchEvent: first arguments should be an event object", exception);
    return nullptr;
  }

  JSEventTarget::EventTargetInstance *eventTargetInstance;

  if (hasProto(ctx, thisObject, exception)) {
    eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(getProto(ctx, thisObject, exception)));
  } else {
    eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(thisObject));
  }
  assert_m(eventTargetInstance != nullptr, "this object is not a instance of eventTarget.");

  const JSValueRef eventObjectValueRef = arguments[0];
  JSObjectRef eventObjectRef = JSValueToObject(ctx, eventObjectValueRef, exception);
  auto eventInstance = reinterpret_cast<EventInstance *>(JSObjectGetPrivate(eventObjectRef));

  return JSValueMakeBoolean(ctx, eventTargetInstance->dispatchEvent(eventInstance));
}

bool JSEventTarget::EventTargetInstance::dispatchEvent(EventInstance *event) {
  auto eventType = static_cast<JSEvent::EventType>(event->nativeEvent->type);

  if (!_eventHandlers.contains(eventType)) {
    return false;
  }

  event->nativeEvent->target = event->nativeEvent->currentTarget = this;

  // event has been dispatched, then do not dispatch
  event->_dispatchFlag = true;
  bool cancelled;

  while (event->nativeEvent->currentTarget != nullptr) {
    cancelled = internalDispatchEvent(event);
    if (event->nativeEvent->bubbles || cancelled) break;
    if (event->nativeEvent->currentTarget != nullptr) {
      auto node = reinterpret_cast<JSNode::NodeInstance *>(event->nativeEvent->currentTarget);
      event->nativeEvent->currentTarget = node->parentNode;
    }
  }

  event->_dispatchFlag = false;
  return !event->_canceledFlag;
}

JSValueRef JSEventTarget::clearListeners(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                             size_t argumentCount, const JSValueRef *arguments, JSValueRef *exception) {
  auto eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(thisObject));
  assert_m(eventTargetInstance != nullptr, "this object is not a instance of eventTarget.");

  for (auto &it : eventTargetInstance->_eventHandlers) {
    for (auto &handler : it.second) {
      JSValueUnprotect(eventTargetInstance->_hostClass->ctx, handler);
    }
  }

  eventTargetInstance->_eventHandlers.clear();
  return nullptr;
}

JSValueRef JSEventTarget::EventTargetInstance::getProperty(std::string &name, JSValueRef *exception) {
  auto propertyMap = getEventTargetPropertyMap();
  if (propertyMap.contains(name)) {
    auto property = propertyMap[name];

    switch (property) {
    case EventTargetProperty::kAddEventListener: {
      return prototype<JSEventTarget>()->m_addEventListener.function();
    }
    case EventTargetProperty::kRemoveEventListener: {
      return prototype<JSEventTarget>()->m_removeEventListener.function();
    }
    case EventTargetProperty::kDispatchEvent: {
      return prototype<JSEventTarget>()->m_dispatchEvent.function();
    }
    case EventTargetProperty::kClearListeners: {
      return prototype<JSEventTarget>()->m_clearListeners.function();
    }
    case EventTargetProperty::kEventTargetId: {
      return JSValueMakeNumber(_hostClass->ctx, eventTargetId);
    }
    }
  } else if (name.substr(0, 2) == "on") {
    return getPropertyHandler(name, exception);
  }

  return Instance::getProperty(name, exception);
}

void JSEventTarget::EventTargetInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  if (name.substr(0, 2) == "on") {
    setPropertyHandler(name, value, exception);
  } else {
    Instance::setProperty(name, value, exception);
  }
}

JSValueRef JSEventTarget::EventTargetInstance::getPropertyHandler(std::string &name, JSValueRef *exception) {
  std::string subName = name.substr(2);

  JSEvent::EventType eventType = JSEvent::getEventTypeOfName(subName);

  if (!_eventHandlers.contains(eventType)) {
    return nullptr;
  }
  return _eventHandlers[eventType].front();
}

void JSEventTarget::EventTargetInstance::setPropertyHandler(std::string &name, JSValueRef value,
                                                            JSValueRef *exception) {
  std::string subName = name.substr(2);
  JSEvent::EventType eventType = JSEvent::getEventTypeOfName(subName);

  if (eventType == JSEvent::EventType::none) return;

  if (_eventHandlers.contains(eventType)) {
    for (auto &it : _eventHandlers) {
      for (auto &handler : it.second) {
        JSValueUnprotect(_hostClass->ctx, handler);
      }
    }
    _eventHandlers[eventType].clear();
  } else {
    _eventHandlers[eventType] = std::deque<JSObjectRef>();
  }

  JSObjectRef handlerObjectRef = JSValueToObject(_hostClass->ctx, value, exception);
  JSValueProtect(_hostClass->ctx, handlerObjectRef);
  _eventHandlers[eventType].emplace_back(handlerObjectRef);

  auto Event = reinterpret_cast<JSEventTarget*>(_hostClass);
  auto isJsOnlyEvent = std::find(Event->m_jsOnlyEvents.begin(), Event->m_jsOnlyEvents.end(), name.substr(2)) != Event->m_jsOnlyEvents.end();

  if (isJsOnlyEvent) return;

  int32_t contextId = _hostClass->contextId;
  std::string eventTypeString = std::to_string(eventType);
  auto args = buildUICommandArgs(eventTypeString);
  foundation::UICommandTaskMessageQueue::instance(contextId)->registerCommand(eventTargetId, UICommand::addEvent,
                                                                              args, 1, nullptr);
}

void JSEventTarget::EventTargetInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &propertyName : getEventTargetPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, propertyName);
  }
}

std::vector<JSStringRef> &JSEventTarget::getEventTargetPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("addEventListener"), JSStringCreateWithUTF8CString("removeEventListener"),
    JSStringCreateWithUTF8CString("dispatchEvent"), JSStringCreateWithUTF8CString("__clearListeners__"),
    JSStringCreateWithUTF8CString("eventTargetId")};
  return propertyNames;
}

bool JSEventTarget::EventTargetInstance::internalDispatchEvent(EventInstance *eventInstance) {
  auto eventType = static_cast<JSEvent::EventType>(eventInstance->nativeEvent->type);
  auto stack = _eventHandlers[eventType];

  for (auto &handler : stack) {
    JSValueRef exception = nullptr;
    const JSValueRef arguments[] = {eventInstance->object};
    JSObjectCallAsFunction(_hostClass->ctx, handler, handler, 1, arguments, &exception);
    context->handleException(exception);
  }

  // do not dispatch event when event has been canceled
  return !eventInstance->_canceledFlag;
}
const std::unordered_map<std::string, JSEventTarget::EventTargetProperty> &JSEventTarget::getEventTargetPropertyMap() {
  static const std::unordered_map<std::string, EventTargetProperty> eventTargetProperty{
    {"addEventListener", EventTargetProperty::kAddEventListener},
    {"removeEventListener", EventTargetProperty::kRemoveEventListener},
    {"dispatchEvent", EventTargetProperty::kDispatchEvent},
    {"__clearListeners__", EventTargetProperty::kClearListeners},
    {"eventTargetId", EventTargetProperty::kEventTargetId}};
  return eventTargetProperty;
}

// This function will be called back by dart side when trigger events.
void NativeEventTarget::dispatchEventImpl(NativeEventTarget *nativeEventTarget, int64_t eventType, void *nativeEvent) {
  assert_m(nativeEventTarget->instance != nullptr, "NativeEventTarget should have owner");

  JSEventTarget::EventTargetInstance *eventTargetInstance = nativeEventTarget->instance;
  JSContext *context = eventTargetInstance->context;

  auto type = static_cast<JSEvent::EventType>(eventType);

  EventInstance *eventInstance;

  if (type == JSEvent::EventType::input) {
    eventInstance = new InputEventInstance(JSInputEvent::instance(context), reinterpret_cast<NativeInputEvent*>(nativeEvent));
  } else {
    eventInstance = new EventInstance(JSEvent::instance(context), reinterpret_cast<NativeEvent*>(nativeEvent));
  }

  eventTargetInstance->dispatchEvent(eventInstance);
}

} // namespace kraken::binding::jsc
