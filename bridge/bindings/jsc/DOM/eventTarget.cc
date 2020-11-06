/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "eventTarget.h"
#include "dart_methods.h"
#include "document.h"
#include "event.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

static std::atomic<int64_t> globalEventTargetId{-2};

void bindEventTarget(std::unique_ptr<JSContext> &context) {
  auto eventTarget = JSEventTarget::instance(context.get());
  JSValueProtect(context->context(), eventTarget->classObject);
  JSC_GLOBAL_SET_PROPERTY(context, "EventTarget", eventTarget->classObject);
}

JSEventTarget *JSEventTarget::instance(JSContext *context) {
  static JSEventTarget *_instance{nullptr};
  if (_instance == nullptr) {
    _instance = new JSEventTarget(context);
  }
  return _instance;
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
  nativeEventTarget = new NativeEventTarget(this, NativeEventTarget::dispatchEventImpl);
}

JSEventTarget::EventTargetInstance::EventTargetInstance(JSEventTarget *eventTarget, int64_t id)
  : Instance(eventTarget), eventTargetId(id) {
  nativeEventTarget = new NativeEventTarget(this, NativeEventTarget::dispatchEventImpl);
}

JSEventTarget::EventTargetInstance::~EventTargetInstance() {
  // Recycle eventTarget object could be triggered by hosting JSContext been released or reference count set to 0.
  auto data = new DisposeCallbackData(_hostClass->context->getContextId(), eventTargetId);
  foundation::Task disposeTask = [](void *data) {
    auto disposeCallbackData = reinterpret_cast<DisposeCallbackData *>(data);
    foundation::UICommandTaskMessageQueue::instance(disposeCallbackData->contextId)
      ->registerCommand(disposeCallbackData->id, UICommandType::disposeEventTarget, nullptr, 0, 0x00);
    delete disposeCallbackData;
  };
  foundation::UITaskMessageQueue::instance()->registerTask(disposeTask, data);

  // Release propertyNames;
  for (auto &propertyName : propertyNames) {
    JSStringRelease(propertyName);
  }

  // Release handler callbacks.
  for (auto &it : _eventHandlers) {
    for (auto &handler : it.second) {
      JSValueUnprotect(_hostClass->ctx, handler);
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
  std::string eventName = JSStringToStdString(eventNameStringRef);
  EventType eventType = EventTypeValues[eventName];

  // this is an bargain optimize for addEventListener which send `addEvent` message to kraken Dart side only once and
  // no one can stop element to trigger event from dart side. this can led to significant performance improvement when
  // using Front-End frameworks such as Rax, or cause some overhead performance issue when some event trigger more
  // frequently.
  if (!eventTargetInstance->_eventHandlers.contains(eventType) ||
      eventTargetInstance->eventTargetId == BODY_TARGET_ID) {
    eventTargetInstance->_eventHandlers[eventType] = std::deque<JSObjectRef>();
    int32_t contextId = eventTargetInstance->_hostClass->context->getContextId();

    JSStringRef eventTypeString = JSStringCreateWithUTF8CString(std::to_string(eventType).c_str());

    NativeString eventNameArgs{};
    eventNameArgs.string = JSStringGetCharactersPtr(eventTypeString);
    eventNameArgs.length = JSStringGetLength(eventTypeString);

    NativeString **args = new NativeString *[1];
    args[0] = eventNameArgs.clone();
    foundation::UICommandTaskMessageQueue::instance(contextId)->registerCommand(eventTargetInstance->eventTargetId,
                                                                                UICommandType::addEvent, args, 1, 0x00);
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
  std::string eventName = JSStringToStdString(eventNameStringRef);
  EventType eventType = EventTypeValues[eventName];

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
  auto eventType = static_cast<EventType>(eventInstance->nativeEvent->type);

  if (!eventTargetInstance->_eventHandlers.contains(eventType)) {
    return nullptr;
  }

  eventInstance->nativeEvent->target = eventInstance->nativeEvent->currentTarget = eventTargetInstance;

  // event has been dispatched, then do not dispatch
  eventInstance->_dispatchFlag = true;
  bool cancelled = true;

  while (eventInstance->nativeEvent->currentTarget != nullptr) {
    cancelled = eventTargetInstance->_dispatchEvent(eventInstance);
    if (eventInstance->nativeEvent->bubbles || cancelled) break;
    if (eventInstance->nativeEvent->currentTarget != nullptr) {
      auto target = reinterpret_cast<JSEventTarget::EventTargetInstance *>(eventInstance->nativeEvent->currentTarget);
      // TODO: event.target = node.parentNode;
    }
  }

  eventInstance->_dispatchFlag = false;
  return JSValueMakeBoolean(ctx, !eventInstance->_canceledFlag);
}

JSValueRef JSEventTarget::EventTargetInstance::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);

  if (name == "addEventListener") {
    return propertyBindingFunction(_hostClass->context, this, "addEventListener", addEventListener);
  } else if (name == "removeEventListener") {
    return propertyBindingFunction(_hostClass->context, this, "removeEventListener", removeEventListener);
  } else if (name == "dispatchEvent") {
    return propertyBindingFunction(_hostClass->context, this, "dispatchEvent", dispatchEvent);
  } else if (name.substr(0, 2) == "on") {
    return getPropertyHandler(name, exception);
  }

  return nullptr;
}

void JSEventTarget::EventTargetInstance::setProperty(JSStringRef nameRef, JSValueRef value, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);

  if (name.substr(0, 2) == "on") {
    setPropertyHandler(name, value, exception);
  }
}

JSValueRef JSEventTarget::EventTargetInstance::getPropertyHandler(std::string &name, JSValueRef *exception) {
  std::string subName = name.substr(2);

  EventType eventType = EventTypeValues[subName];

  if (!_eventHandlers.contains(eventType)) {
    return nullptr;
  }
  return _eventHandlers[eventType].front();
}

void JSEventTarget::EventTargetInstance::setPropertyHandler(std::string &name, JSValueRef value,
                                                            JSValueRef *exception) {
  std::string subName = name.substr(2);
  EventType eventType = EventTypeValues[subName];

  if (eventType == EventType::none) return;

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

  int32_t contextId = _hostClass->context->getContextId();

  JSStringRef eventTypeString = JSStringCreateWithUTF8CString(std::to_string(eventType).c_str());

  NativeString eventNameArgs{};
  eventNameArgs.string = JSStringGetCharactersPtr(eventTypeString);
  eventNameArgs.length = JSStringGetLength(eventTypeString);

  NativeString **args = new NativeString *[1];
  args[0] = eventNameArgs.clone();
  foundation::UICommandTaskMessageQueue::instance(contextId)->registerCommand(eventTargetId,
                                                                              UICommandType::addEvent, args, 1, 0x00);
}

void JSEventTarget::EventTargetInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &propertyName : propertyNames) {
    JSPropertyNameAccumulatorAddName(accumulator, propertyName);
  }
}

bool JSEventTarget::EventTargetInstance::_dispatchEvent(JSEvent::EventInstance *eventInstance) {
  auto eventType = static_cast<EventType>(eventInstance->nativeEvent->type);
  auto stack = _eventHandlers[eventType];

  for (auto &handler : stack) {
    JSValueRef exception = nullptr;
    const JSValueRef arguments[] = {eventInstance->object};
    JSObjectCallAsFunction(_hostClass->ctx, handler, handler, 1, arguments, &exception);
    _hostClass->context->handleException(exception);
  }

  // do not dispatch event when event has been canceled
  return !eventInstance->_canceledFlag;
}

// This function will be called back by dart side when trigger events.
void NativeEventTarget::dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeEvent *nativeEvent) {
  JSEventTarget::EventTargetInstance *eventTargetInstance = nativeEventTarget->instance;
  JSContext *context = eventTargetInstance->_hostClass->context;
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
