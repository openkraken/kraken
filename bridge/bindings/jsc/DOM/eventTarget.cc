/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "eventTarget.h"
#include "dart_methods.h"
#include "document.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {

static std::atomic<int64_t> globalEventTargetId{-2};

JSEventTarget::JSEventTarget(JSContext *context, const char *name) : HostClass(context, name) {}
JSEventTarget::JSEventTarget(JSContext *context) : HostClass(context, "EventTarget") {}

JSValueRef JSEventTarget::prototypeGetProperty(Instance *instance, JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);

  if (name == "addEventListener") {
    return propertyBindingFunction(context, instance, "addEventListener", addEventListener);
  } else if (name == "removeEventListener") {
    return propertyBindingFunction(context, instance, "removeEventListener", removeEventListener);
  } else if (name == "dispatchEvent") {
    return propertyBindingFunction(context, instance, "dispatchEvent", dispatchEvent);
  }

  return nullptr;
}

JSValueRef JSEventTarget::addEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                           size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception) {
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

  // this is an bargain optimize for addEventListener which send `addEvent` message to kraken Dart side only once and
  // no one can stop element to trigger event from dart side. this can led to significant performance improvement when
  // using Front-End frameworks such as Rax, or cause some overhead performance issue when some event trigger more
  // frequently.
  if (!eventTargetInstance->_eventHandlers.contains(eventName) ||
      eventTargetInstance->eventTargetId == BODY_TARGET_ID) {
    std::deque<JSObjectRef> handlers;
    eventTargetInstance->_eventHandlers[eventName] = std::move(handlers);
    int32_t contextId = eventTargetInstance->_hostClass->context->getContextId();

    NativeString eventNameArgs{};
    eventNameArgs.string = JSStringGetCharactersPtr(eventNameStringRef);
    eventNameArgs.length = JSStringGetLength(eventNameStringRef);

    NativeString *args[1] = {eventNameArgs.clone()};
    foundation::UICommandTaskMessageQueue::instance(contextId)->registerCommand(eventTargetInstance->eventTargetId,
                                                                                UICommandType::addEvent, args, 1);
  }

  std::deque<JSObjectRef> &handlers = eventTargetInstance->_eventHandlers[eventName];
  JSValueProtect(ctx, callbackObjectRef);
  handlers.emplace_back(callbackObjectRef);

  return nullptr;
}

JSValueRef JSEventTarget::removeEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                              size_t argumentCount, const JSValueRef *arguments,
                                              JSValueRef *exception) {
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

  if (!eventTargetInstance->_eventHandlers.contains(eventName)) {
    return nullptr;
  }

  std::deque<JSObjectRef> &handlers = eventTargetInstance->_eventHandlers[eventName];
  auto begin = std::begin(handlers);
  auto end = std::end(handlers);

  while (begin != end) {
    if (*begin == callbackObjectRef) {
      handlers.erase(begin);
      JSValueUnprotect(ctx, callbackObjectRef);
    } else {
      begin++;
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

  // TODO implement event object;
  return nullptr;
}

JSEventTarget::EventTargetInstance::EventTargetInstance(JSEventTarget *eventTarget) : Instance(eventTarget) {
  eventTargetId = globalEventTargetId;
  globalEventTargetId++;
}

JSEventTarget::EventTargetInstance::~EventTargetInstance() {
  // Recycle eventTarget object could be triggered by hosting JSContext been released or reference count set to 0.
  auto data = new DisposeCallbackData(_hostClass->context->getContextId(), eventTargetId);
  foundation::Task disposeTask = [](void *data) {
    auto disposeCallbackData = reinterpret_cast<DisposeCallbackData *>(data);
    foundation::UICommandTaskMessageQueue::instance(disposeCallbackData->contextId)
      ->registerCommand(disposeCallbackData->id, UICommandType::disposeEventTarget, nullptr, 0);
    delete disposeCallbackData;
  };
  foundation::UITaskMessageQueue::instance()->registerTask(disposeTask, data);
}

} // namespace kraken::binding::jsc
