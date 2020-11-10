/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event.h"
#include "eventTarget.h"
#include <chrono>

namespace kraken::binding::jsc {

void bindEvent(std::unique_ptr<JSContext> &context) {
  auto event = JSEvent::instance(context.get());
  JSC_GLOBAL_SET_PROPERTY(context, "Event", event->classObject);
};

JSEvent *JSEvent::instance(JSContext *context) {
  static std::unordered_map<JSContext *, JSEvent*> instanceMap {};
  if (!instanceMap.contains(context)) {
    instanceMap[context] = new JSEvent(context);
  }
  return instanceMap[context];
}

JSEvent::JSEvent(JSContext *context) : HostClass(context, "Event") {}
JSEvent::JSEvent(JSContext *context, const char *name) : HostClass(context, name) {}

JSObjectRef JSEvent::instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                       const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount != 1) {
    JSC_THROW_ERROR(ctx, "Failed to construct 'Event': 1 argument required, but only 0 present.", exception);
    return nullptr;
  }

  const JSValueRef eventTypeValueRef = arguments[0];
  JSStringRef eventTypeStringRef = JSValueToStringCopy(ctx, eventTypeValueRef, exception);
  std::string &&eventTypeName = JSStringToStdString(eventTypeStringRef);
  EventType eventType = EventTypeValues[eventTypeName];
  auto event = new EventInstance(this, eventType);
  return event->object;
}

JSEvent::EventInstance::EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent)
  : Instance(jsEvent), nativeEvent(nativeEvent) {}

JSEvent::EventInstance::EventInstance(JSEvent *jsEvent, EventType eventType) : Instance(jsEvent) {
  nativeEvent = new NativeEvent(eventType);
  auto ms = duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch());
  nativeEvent->timeStamp = ms.count();
}

JSValueRef JSEvent::EventInstance::getProperty(JSStringRef nameRef, JSValueRef *exception) {
  std::string &&name = JSStringToStdString(nameRef);

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
  } else if (name == "target" || name == "srcElement") {
    if (nativeEvent->target != nullptr) {
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->target);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  } else if (name == "currentTarget") {
    if (nativeEvent->currentTarget != nullptr) {
      auto instance = reinterpret_cast<JSEventTarget::EventTargetInstance *>(nativeEvent->currentTarget);
      return instance->object;
    }
    return JSValueMakeNull(_hostClass->ctx);
  } else if (name == "returnValue") {
    return JSValueMakeBoolean(_hostClass->ctx, !_canceledFlag);
  } else if (name == "defaultPrevented") {
    return JSValueMakeBoolean(_hostClass->ctx, _canceledFlag);
  } else if (name == "stopPropagation") {
    if (_stopPropagation == nullptr) {
      _stopPropagation = propertyBindingFunction(_hostClass->context, this, "stopPropagation", stopPropagation);
    }
    return _stopPropagation;
  } else if (name == "cancelBubble") {
    return JSValueMakeBoolean(_hostClass->ctx, _stopPropagationFlag);
  } else if (name == "stopImmediatePropagation") {
    if (_stopImmediatePropagation == nullptr) {
      _stopImmediatePropagation = propertyBindingFunction(_hostClass->context, this, "stopImmediatePropagation", stopImmediatePropagation);
    }
    return _stopImmediatePropagation;
  } else if (name == "preventDefault") {
    if (_preventDefault == nullptr) {
      _preventDefault = propertyBindingFunction(_hostClass->context, this, "preventDefault", preventDefault);
    }
    return _preventDefault;
  }

  return nullptr;
}

JSValueRef JSEvent::EventInstance::stopPropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                   size_t argumentCount, const JSValueRef *arguments,
                                                   JSValueRef *exception) {
  auto eventInstance = static_cast<JSEvent::EventInstance *>(JSObjectGetPrivate(function));
  eventInstance->_stopPropagationFlag = true;
  return nullptr;
}

JSValueRef JSEvent::EventInstance::stopImmediatePropagation(JSContextRef ctx, JSObjectRef function,
                                                            JSObjectRef thisObject, size_t argumentCount,
                                                            const JSValueRef *arguments, JSValueRef *exception) {
  auto eventInstance = static_cast<JSEvent::EventInstance *>(JSObjectGetPrivate(function));
  eventInstance->_stopPropagationFlag = true;
  eventInstance->_stopImmediatePropagationFlag = true;
  return nullptr;
}

JSValueRef JSEvent::EventInstance::preventDefault(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                                  size_t argumentCount, const JSValueRef *arguments,
                                                  JSValueRef *exception) {
  auto eventInstance = static_cast<JSEvent::EventInstance *>(JSObjectGetPrivate(function));
  if (eventInstance->nativeEvent->cancelable && !eventInstance->_inPassiveListenerFlag) {
    eventInstance->_canceledFlag = true;
  }
  return nullptr;
}

void JSEvent::EventInstance::setProperty(JSStringRef nameRef, JSValueRef value, JSValueRef *exception) {
  std::string &&name = JSStringToStdString(nameRef);

  if (name == "cancelBubble") {
    bool v = JSValueToBoolean(_hostClass->ctx, value);
    if (v) {
      _stopPropagationFlag = true;
    }
  }
}

JSEvent::EventInstance::~EventInstance() {
  delete nativeEvent;
}
void JSEvent::EventInstance::getPropertyNames(JSPropertyNameAccumulatorRef accumulator) {
  for (auto &property : getEventPropertyNames()) {
    JSPropertyNameAccumulatorAddName(accumulator, property);
  }
}

std::array<JSStringRef, 8> &JSEvent::EventInstance::getEventPropertyNames() {
  static std::array<JSStringRef, 8> propertyNames{
      JSStringCreateWithUTF8CString("type"),
      JSStringCreateWithUTF8CString("bubbles"),
      JSStringCreateWithUTF8CString("cancelable"),
      JSStringCreateWithUTF8CString("timeStamp"),
      JSStringCreateWithUTF8CString("defaultPrevented"),
      JSStringCreateWithUTF8CString("targetId"),
      JSStringCreateWithUTF8CString("currentTarget"),
      JSStringCreateWithUTF8CString("srcElement"),
  };
  return propertyNames;
}

} // namespace kraken::binding::jsc
