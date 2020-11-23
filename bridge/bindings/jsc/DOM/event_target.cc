/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"
#include "dart_methods.h"
#include "document.h"
#include "event.h"
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
    instanceMap[context] = new JSEventTarget(context);
  }
  return instanceMap[context];
}

JSEventTarget::JSEventTarget(JSContext *context, const char *name) : HostClass(context, name) {}
JSEventTarget::JSEventTarget(JSContext *context) : HostClass(context, "EventTarget") {}

JSObjectRef JSEventTarget::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                               const JSValueRef *arguments, JSValueRef *exception) {
  return HostClass::instanceConstructor(ctx, constructor, argumentCount, arguments, exception);
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
          ->registerCommand(disposeCallbackData->id, UI_COMMAND_DISPOSE_EVENT_TARGET, nullptr, 0, nullptr);
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

JSValueRef JSEventTarget::EventTargetInstance::addEventListener(JSContextRef ctx, JSObjectRef function,
                                                                JSObjectRef thisObject, size_t argumentCount,
                                                                const JSValueRef arguments[], JSValueRef *exception) {
  if (argumentCount != 2) {
    JSC_THROW_ERROR(ctx, "Failed to addEventListener: eventName and function parameter are required.", exception);
    return nullptr;
  }

  auto eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(function));

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

    foundation::UICommandTaskMessageQueue::instance(contextId)->registerCommand(eventTargetInstance->eventTargetId,
                                                                                UI_COMMAND_ADD_EVENT, args, 1, 0x00);
  }

  std::deque<JSObjectRef> &handlers = eventTargetInstance->_eventHandlers[eventType];
  JSValueProtect(ctx, callbackObjectRef);
  handlers.emplace_back(callbackObjectRef);

  return nullptr;
}

JSValueRef JSEventTarget::EventTargetInstance::removeEventListener(JSContextRef ctx, JSObjectRef function,
                                                                   JSObjectRef thisObject, size_t argumentCount,
                                                                   const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 2) {
    JSC_THROW_ERROR(ctx, "Failed to removeEventListener: eventName and function parameter are required.", exception);
    return nullptr;
  }

  auto eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(function));

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

JSValueRef JSEventTarget::EventTargetInstance::dispatchEvent(JSContextRef ctx, JSObjectRef function,
                                                             JSObjectRef thisObject, size_t argumentCount,
                                                             const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to dispatchEvent: first arguments should be an event object", exception);
    return nullptr;
  }

  auto eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(function));
  const JSValueRef eventObjectValueRef = arguments[0];
  JSObjectRef eventObjectRef = JSValueToObject(ctx, eventObjectValueRef, exception);
  auto eventInstance = reinterpret_cast<JSEvent::EventInstance *>(JSObjectGetPrivate(eventObjectRef));
  auto eventType = static_cast<JSEvent::EventType>(eventInstance->nativeEvent->type);

  if (!eventTargetInstance->_eventHandlers.contains(eventType)) {
    return nullptr;
  }

  eventInstance->nativeEvent->target = eventInstance->nativeEvent->currentTarget = eventTargetInstance;

  // event has been dispatched, then do not dispatch
  eventInstance->_dispatchFlag = true;
  bool cancelled;

  while (eventInstance->nativeEvent->currentTarget != nullptr) {
    cancelled = eventTargetInstance->internalDispatchEvent(eventInstance);
    if (eventInstance->nativeEvent->bubbles || cancelled) break;
    if (eventInstance->nativeEvent->currentTarget != nullptr) {
      auto node = reinterpret_cast<JSNode::NodeInstance *>(eventInstance->nativeEvent->currentTarget);
      eventInstance->nativeEvent->currentTarget = node->parentNode;
    }
  }

  eventInstance->_dispatchFlag = false;
  return JSValueMakeBoolean(ctx, !eventInstance->_canceledFlag);
}

JSValueRef JSEventTarget::EventTargetInstance::__clearListeners__(JSContextRef ctx, JSObjectRef function,
                                                                  JSObjectRef thisObject, size_t argumentCount,
                                                                  const JSValueRef *arguments, JSValueRef *exception) {
  auto eventTargetInstance = static_cast<JSEventTarget::EventTargetInstance *>(JSObjectGetPrivate(function));

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
      return m_addEventListener.function();
    }
    case EventTargetProperty::kRemoveEventListener: {
      return m_removeEventListener.function();
    }
    case EventTargetProperty::kDispatchEvent: {
      return m_dispatchEvent.function();
    }
    case EventTargetProperty::kClearListeners: {
      return m_clearListeners.function();
    }
    case EventTargetProperty::kTargetId: {
      return JSValueMakeNumber(_hostClass->ctx, eventTargetId);
    }
    }
  } else if (name.substr(0, 2) == "on") {
    return getPropertyHandler(name, exception);
  }

  return nullptr;
}

void JSEventTarget::EventTargetInstance::setProperty(std::string &name, JSValueRef value, JSValueRef *exception) {
  if (name.substr(0, 2) == "on") {
    setPropertyHandler(name, value, exception);
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

  int32_t contextId = _hostClass->contextId;

  std::string eventTypeString = std::to_string(eventType);
  auto args = buildUICommandArgs(eventTypeString);
  foundation::UICommandTaskMessageQueue::instance(contextId)->registerCommand(eventTargetId, UI_COMMAND_ADD_EVENT,
                                                                              args, 1, nullptr);
}

void JSEventTarget::EventTargetInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &propertyName : getEventTargetPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, propertyName);
  }
}

std::vector<JSStringRef> &JSEventTarget::EventTargetInstance::getEventTargetPropertyNames() {
  static std::vector<JSStringRef> propertyNames{
    JSStringCreateWithUTF8CString("addEventListener"), JSStringCreateWithUTF8CString("removeEventListener"),
    JSStringCreateWithUTF8CString("dispatchEvent"), JSStringCreateWithUTF8CString("__clearListeners__"), JSStringCreateWithUTF8CString("targetId")};
  return propertyNames;
}

bool JSEventTarget::EventTargetInstance::internalDispatchEvent(JSEvent::EventInstance *eventInstance) {
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
const std::unordered_map<std::string, JSEventTarget::EventTargetInstance::EventTargetProperty> &
JSEventTarget::EventTargetInstance::getEventTargetPropertyMap() {
  static const std::unordered_map<std::string, EventTargetProperty> eventTargetProperty{
    {"addEventListener", EventTargetProperty::kAddEventListener},
    {"removeEventListener", EventTargetProperty::kRemoveEventListener},
    {"dispatchEvent", EventTargetProperty::kDispatchEvent},
    {"__clearListeners__", EventTargetProperty::kClearListeners},
    {"targetId", EventTargetProperty::kTargetId}};
  return eventTargetProperty;
}

// This function will be called back by dart side when trigger events.
void NativeEventTarget::dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeEvent *nativeEvent) {
  JSEventTarget::EventTargetInstance *eventTargetInstance = nativeEventTarget->instance;
  JSContext *context = eventTargetInstance->context;
  JSContextRef ctx = eventTargetInstance->_hostClass->ctx;

  JSValueRef exception = nullptr;
  auto eventInstance = new JSEvent::EventInstance(JSEvent::instance(context), nativeEvent);
  JSStringRef dispatchStringRef = JSStringCreateWithUTF8CString("dispatchEvent");
  JSValueRef dispatchFunctionValueRef =
    JSObjectGetProperty(ctx, eventTargetInstance->object, dispatchStringRef, &exception);
  JSObjectRef dispatchObjectRef = JSValueToObject(ctx, dispatchFunctionValueRef, &exception);

  const JSValueRef dispatchArguments[] = {eventInstance->object};
  JSObjectCallAsFunction(ctx, dispatchObjectRef, dispatchObjectRef, 1, dispatchArguments, &exception);
  context->handleException(exception);
}

} // namespace kraken::binding::jsc
