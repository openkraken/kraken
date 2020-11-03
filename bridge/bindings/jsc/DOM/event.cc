/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "eventTarget.h"

namespace kraken::binding::jsc {

void bindEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSEvent::instance(context.get());
  JSValueProtect(context->context(), event->classObject);
  JSC_GLOBAL_SET_PROPERTY(context, "Event", event->classObject);
};

namespace {
JSEvent *_instance{nullptr};
}

JSEvent *JSEvent::instance(JSContext *context) {
  if (_instance == nullptr) {
    _instance = new JSEvent(context);
  }
  return _instance;
}

JSEvent::JSEvent(JSContext *context) : HostClass(context, "Event") {}
JSEvent::JSEvent(JSContext *context, const char *name) : HostClass(context, name) {}

JSObjectRef JSEvent::constructInstance(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                       const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to construct 'Event': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  const JSValueRef eventTypeValueRef = arguments[0];
  JSStringRef eventTypeStringRef = JSValueToStringCopy(ctx, eventTypeValueRef, exception);
  std::string eventTypeName = JSStringToStdString(eventTypeStringRef);
  EventType eventType = EventTypeValues[eventTypeName];
  auto event = new EventInstance(this, eventType);
  return event->object;
}

JSEvent::EventInstance::EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent)
  : Instance(jsEvent), nativeEvent(nativeEvent) {}

JSEvent::EventInstance::EventInstance(JSEvent *jsEvent, EventType eventType) : Instance(jsEvent) {
  nativeEvent = new NativeEvent(eventType);
}

JSValueRef JSEvent::EventInstance::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string name = JSStringToStdString(nameRef);

  if (name == "type") {
    JSStringRef eventStringRef = JSStringCreateWithUTF8CString(EventTypeKeys[nativeEvent->type]);
    return JSValueMakeString(_hostClass->ctx, eventStringRef);
  } else if (name == "bubbles") {
    return JSValueMakeBoolean(_hostClass->ctx, nativeEvent->bubbles);
  } else if (name == "cancelable") {
    return JSValueMakeBoolean(_hostClass->ctx, nativeEvent->cancelable);
  } else if (name == "timeStamp") {
    return JSValueMakeNumber(_hostClass->ctx, nativeEvent->timeStamp);
  } else if (name == "defaultPrevented") {
    return JSValueMakeBoolean(_hostClass->ctx, nativeEvent->defaultPrevented);
  } else if (name == "targetId") {
    if (nativeEvent->targetId != 0) {
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->targetId);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  } else if (name == "currentTarget") {
    if (nativeEvent->currentTarget != 0) {
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->currentTarget);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  }

  return nullptr;
}

} // namespace kraken::binding::jsc
