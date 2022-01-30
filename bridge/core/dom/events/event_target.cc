/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include <utility>

#include "event_target.h"
#include "bindings/qjs/qjs_patch.h"
#include "custom_event.h"
#include "event.h"
#include "core/dom/node.h"
#include "core/frame/window.h"

#if UNIT_TEST
#include "kraken_test_env.h"
#endif

namespace kraken {

static std::atomic<int32_t> globalEventTargetId{0};
#define GetPropertyCallPreFix "_getProperty_"

void bindEventTarget(std::unique_ptr<ExecutionContext>& context) {
  JSValue constructor = EventTarget::constructor(context.get());
  JSValue prototypeObject = EventTarget::prototype(context.get());

  INSTALL_FUNCTION(EventTarget, prototypeObject, addEventListener, 3);
  INSTALL_FUNCTION(EventTarget, prototypeObject, removeEventListener, 2);
  INSTALL_FUNCTION(EventTarget, prototypeObject, dispatchEvent, 1);

  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  JS_SetPrototype(context->ctx(), context->global(), constructor);
  context->defineGlobalProperty("EventTarget", constructor);
}

EventTarget::EventTarget() : GarbageCollected<EventTarget>() {
  m_eventTargetId = globalEventTargetId++;
}

IMPL_FUNCTION(EventTarget, addEventListener)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: type and listener are required.");
  }

  auto* eventTarget = static_cast<EventTarget*>(JS_GetOpaque(this_val, EventTarget::classId));
  if (eventTarget == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue eventTypeValue = argv[0];
  JSValue callback = argv[1];

  if (!JS_IsString(eventTypeValue) || !JS_IsObject(callback) || !JS_IsFunction(ctx, callback)) {
    return JS_UNDEFINED;
  }

  // EventType atom will be freed when eventTarget finalized.
  JSAtom eventType = JS_ValueToAtom(ctx, eventTypeValue);

  // Dart needs to be notified for the first registration event.
  if (!eventTarget->m_eventListenerMap.contains(eventType) || eventTarget->m_eventHandlerMap.contains(eventType)) {
    NativeString args_01{};
    buildUICommandArgs(ctx, eventTypeValue, args_01);

    eventTarget->context()->uiCommandBuffer()->addCommand(eventTarget->m_eventTargetId, UICommand::addEvent, args_01, nullptr);
  }

  bool success = eventTarget->m_eventListenerMap.add(eventType, JS_DupValue(ctx, callback));
  // Callback didn't saved to eventListenerMap.
  if (!success) {
    JS_FreeAtom(ctx, eventType);
    JS_FreeValue(ctx, callback);
  }

  return JS_UNDEFINED;
}

IMPL_FUNCTION(EventTarget, removeEventListener)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: at least type and listener are required.");
  }

  auto* eventTarget = static_cast<EventTarget*>(JS_GetOpaque(this_val, EventTarget::classId));
  if (eventTarget == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue eventTypeValue = argv[0];
  JSValue callback = argv[1];

  if (!JS_IsString(eventTypeValue) || !JS_IsObject(callback) || !JS_IsObject(callback)) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: eventName should be an string.");
  }

  JSAtom eventType = JS_ValueToAtom(ctx, eventTypeValue);
  auto& eventHandlers = eventTarget->m_eventListenerMap;

  if (!eventTarget->m_eventListenerMap.contains(eventType)) {
    JS_FreeAtom(ctx, eventType);
    return JS_UNDEFINED;
  }

  if (eventHandlers.remove(eventType, callback)) {
    JS_FreeAtom(ctx, eventType);
    JS_FreeValue(ctx, callback);
  }

  if (eventHandlers.empty() && eventTarget->m_eventHandlerMap.contains(eventType)) {
    NativeString args_01{};
    buildUICommandArgs(ctx, eventTypeValue, args_01);

    eventTarget->context()->uiCommandBuffer()->addCommand(eventTarget->m_eventTargetId, UICommand::removeEvent, args_01, nullptr);
  }

  JS_FreeAtom(ctx, eventType);
  return JS_UNDEFINED;
}

IMPL_FUNCTION(EventTarget, dispatchEvent)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to dispatchEvent: first arguments should be an event object");
  }

  auto* eventTarget = static_cast<EventTarget*>(JS_GetOpaque(this_val, EventTarget::classId));
  if (eventTarget == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue eventValue = argv[0];
  auto event = reinterpret_cast<Event*>(JS_GetOpaque(eventValue, EventTarget::classId));
  return JS_NewBool(ctx, eventTarget->dispatchEvent(event));
}

EventTarget* EventTarget::create(JSContext* ctx) {
  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  JSValue prototype = context->contextData()->prototypeForType(&eventTargetTypeInfo);
  auto* eventTarget = makeGarbageCollected<EventTarget>()->initialize<EventTarget>(ctx, &EventTarget::classId, nullptr);

  // Let eventTarget instance inherit EventTarget prototype methods.
  JS_SetPrototype(ctx, eventTarget->toQuickJS(), prototype);

  return eventTarget;
}

JSValue EventTarget::constructor(ExecutionContext* context) {
  return context->contextData()->constructorForType(&eventTargetTypeInfo);
}

JSValue EventTarget::prototype(ExecutionContext* context) {
  return context->contextData()->prototypeForType(&eventTargetTypeInfo);
}

bool EventTarget::dispatchEvent(Event* event) {
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t*>(event->nativeEvent->type->string), event->nativeEvent->type->length);
  std::string eventType = toUTF8(u16EventType);

  // protect this util event trigger finished.
  JS_DupValue(m_ctx, jsObject);

  internalDispatchEvent(event);

  // Bubble event to root event target.
  if (event->nativeEvent->bubbles == 1 && !event->propagationStopped()) {
    auto node = reinterpret_cast<Node*>(this);
    auto* parent = static_cast<Node*>(JS_GetOpaque(node->parentNode, JSValueGetClassId(node->parentNode)));

    if (parent != nullptr) {
      parent->dispatchEvent(event);
    } else {
      // Window does not inherit from Node, so it is not in the Node tree and needs to continue passing to the Window when it bubbles to Document.
      JSValue globalObjectValue = JS_GetGlobalObject(m_ctx);
      auto* window = static_cast<Window*>(JS_GetOpaque(globalObjectValue, JSValueGetClassId(globalObjectValue)));
      window->internalDispatchEvent(event);
      JS_FreeValue(m_ctx, globalObjectValue);
    }
  }

  JS_FreeValue(m_ctx, jsObject);

  return event->cancelled();
}

bool EventTarget::internalDispatchEvent(Event* event) {
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t*>(event->nativeEvent->type->string), event->nativeEvent->type->length);
  std::string eventTypeStr = toUTF8(u16EventType);
  JSAtom eventType = JS_NewAtom(m_ctx, eventTypeStr.c_str());

  // Modify the currentTarget to this.
  event->nativeEvent->currentTarget = this;

  // Dispatch event listeners writen by addEventListener
  auto _dispatchEvent = [&event, this](JSValue handler) {
    if (!JS_IsFunction(m_ctx, handler))
      return;

    if (event->propagationImmediatelyStopped())
      return;

    /* 'handler' might be destroyed when calling itself (if it frees the
     handler), so must take extra care */
    JS_DupValue(m_ctx, handler);

    JSValue arguments[] = {event->toQuickJS()};

    // The third params `thisObject` to null equals global object.
    JSValue returnedValue = JS_Call(m_ctx, handler, JS_NULL, 1, arguments);

    JS_FreeValue(m_ctx, handler);
    context()->handleException(&returnedValue);
    context()->drainPendingPromiseJobs();
    JS_FreeValue(m_ctx, returnedValue);
  };

  if (m_eventListenerMap.contains(eventType)) {
    const EventListenerVector* vector = m_eventListenerMap.find(eventType);
    for (auto& eventHandler : *vector) {
      _dispatchEvent(eventHandler);
    }
  }

  // Dispatch event listener white by 'on' prefix property.
  if (m_eventHandlerMap.contains(eventType)) {
    // Let special error event handling be true if event is an ErrorEvent.
    bool specialErrorEventHanding = eventTypeStr == "error";

    if (specialErrorEventHanding) {
      auto _dispatchErrorEvent = [&event, this, eventTypeStr](JSValue handler) {
        JSValue error = JS_GetPropertyStr(m_ctx, event->toQuickJS(), "error");
        JSValue messageValue = JS_GetPropertyStr(m_ctx, error, "message");
        JSValue lineNumberValue = JS_GetPropertyStr(m_ctx, error, "lineNumber");
        JSValue fileNameValue = JS_GetPropertyStr(m_ctx, error, "fileName");
        JSValue columnValue = JS_NewUint32(m_ctx, 0);

        JSValue args[]{messageValue, fileNameValue, lineNumberValue, columnValue, error};
        JSValue returnValue = JS_Call(m_ctx, handler, event->toQuickJS(), 5, args);
        context()->drainPendingPromiseJobs();
        context()->handleException(&returnValue);

        JS_FreeValue(m_ctx, error);
        JS_FreeValue(m_ctx, messageValue);
        JS_FreeValue(m_ctx, fileNameValue);
        JS_FreeValue(m_ctx, lineNumberValue);
        JS_FreeValue(m_ctx, columnValue);
      };
      _dispatchErrorEvent(m_eventHandlerMap.getProperty(eventType));
    } else {
      _dispatchEvent(m_eventHandlerMap.getProperty(eventType));
    }
  }

  JS_FreeAtom(m_ctx, eventType);

  // do not dispatch event when event has been canceled
  // true is prevented.
  return event->cancelled();
}

int EventTarget::hasProperty(JSContext* ctx, JSValue obj, JSAtom atom) {
  auto* eventTarget = static_cast<EventTarget*>(JS_GetOpaque(obj, EventTarget::classId));
  JSValue prototype = eventTarget->context()->contextData()->prototypeForType(&eventTargetTypeInfo);

  if (JS_HasProperty(ctx, prototype, atom))
    return true;

  JSValue atomString = JS_AtomToString(ctx, atom);
  JSString* p = JS_VALUE_GET_STRING(atomString);
  // There are still one reference_count in atom. It's safe to free here.
  JS_FreeValue(ctx, atomString);

  if (!p->is_wide_char && p->u.str8[0] == 'o' && p->u.str8[1] == 'n') {
    return !JS_IsNull(eventTarget->getAttributesEventHandler(p));
  }

  return eventTarget->m_properties.contains(atom);
}

JSValue EventTarget::getProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  auto* eventTarget = static_cast<EventTarget*>(JS_GetOpaque(obj, JSValueGetClassId(obj)));
  JSValue prototype = JS_GetPrototype(ctx, eventTarget->jsObject);
  if (JS_HasProperty(ctx, prototype, atom)) {
    JSValue ret = JS_GetPropertyInternal(ctx, prototype, atom, eventTarget->jsObject, 0);
    JS_FreeValue(ctx, prototype);
    return ret;
  }
  JS_FreeValue(ctx, prototype);

  JSValue atomString = JS_AtomToString(ctx, atom);
  JSString* p = JS_VALUE_GET_STRING(atomString);
  // There are still one reference_count in atom. It's safe to free here.
  JS_FreeValue(ctx, atomString);

  if (!p->is_wide_char && p->u.str8[0] == 'o' && p->u.str8[1] == 'n') {
    return eventTarget->getAttributesEventHandler(p);
  }

  if (eventTarget->m_properties.contains(atom)) {
    return JS_DupValue(ctx, eventTarget->m_properties.getProperty(atom));
  }

  // For plugin elements, try to auto generate properties and functions from dart response.
  if (isJavaScriptExtensionElementInstance(eventTarget->context(), eventTarget->jsObject)) {
    const char* cmethod = JS_AtomToCString(eventTarget->m_ctx, atom);
    // Property starts with underscore are taken as private property in javascript object.
    if (cmethod[0] == '_') {
      JS_FreeCString(eventTarget->m_ctx, cmethod);
      return JS_UNDEFINED;
    }
    JSValue result = eventTarget->getNativeProperty(cmethod);
    JS_FreeCString(ctx, cmethod);
    return result;
  }

  return JS_UNDEFINED;
}

int EventTarget::setProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  auto* eventTarget = static_cast<EventTarget*>(JS_GetOpaque(obj, EventTarget::classId));
  JSValue prototype = JS_GetPrototype(ctx, eventTarget->jsObject);

  // Check there are setter functions on prototype.
  if (JS_HasProperty(ctx, prototype, atom)) {
    // Read setter function from prototype Object.
    JSPropertyDescriptor descriptor;
    JS_GetOwnProperty(ctx, &descriptor, prototype, atom);
    JSValue setterFunc = descriptor.setter;
    assert_m(JS_IsFunction(ctx, setterFunc), "Setter on prototype should be an function.");
    JSValue ret = JS_Call(ctx, setterFunc, eventTarget->jsObject, 1, &value);
    if (JS_IsException(ret))
      return -1;

    JS_FreeValue(ctx, ret);
    JS_FreeValue(ctx, descriptor.setter);
    JS_FreeValue(ctx, descriptor.getter);
    JS_FreeValue(ctx, prototype);
    return 1;
  }

  JS_FreeValue(ctx, prototype);

  JSValue atomString = JS_AtomToString(ctx, atom);
  JSString* p = JS_VALUE_GET_STRING(atomString);

  if (!p->is_wide_char && p->len > 2 && p->u.str8[0] == 'o' && p->u.str8[1] == 'n') {
    eventTarget->setAttributesEventHandler(p, value);
  } else {
    eventTarget->m_properties.setProperty(JS_DupAtom(ctx, atom), JS_DupValue(ctx, value));
    if (isJavaScriptExtensionElementInstance(eventTarget->context(), eventTarget->jsObject) && !p->is_wide_char && p->u.str8[0] != '_') {
      std::unique_ptr<NativeString> args_01 = atomToNativeString(ctx, atom);
      std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, value);
      eventTarget->context()->uiCommandBuffer()->addCommand(eventTarget->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
    }
  }

  JS_FreeValue(ctx, atomString);

  return 0;
}

int EventTarget::deleteProperty(JSContext* ctx, JSValue obj, JSAtom prop) {
  return 0;
}

JSValue EventTarget::callNativeMethods(const char* method, int32_t argc, NativeValue* argv) {
  if (nativeEventTarget->callNativeMethods == nullptr) {
    return JS_ThrowTypeError(m_ctx, "Failed to call native dart methods: callNativeMethods not initialized.");
  }

  std::u16string methodString;
  fromUTF8(method, methodString);

  NativeString m{reinterpret_cast<const uint16_t*>(methodString.c_str()), static_cast<uint32_t>(methodString.size())};

  NativeValue nativeValue{};
  nativeEventTarget->callNativeMethods(nativeEventTarget, &nativeValue, &m, argc, argv);
  JSValue returnValue = nativeValueToJSValue(context(), nativeValue);
  return returnValue;
}

void EventTarget::setAttributesEventHandler(JSString* p, JSValue value) {
  char eventType[p->len + 1 - 2];
  memcpy(eventType, &p->u.str8[2], p->len + 1 - 2);
  JSAtom atom = JS_NewAtom(m_ctx, eventType);

  // When evaluate scripts like 'element.onclick = null', we needs to remove the event handlers callbacks
  if (JS_IsNull(value)) {
    m_eventHandlerMap.erase(atom);
    JS_FreeAtom(m_ctx, atom);
    return;
  }

  m_eventHandlerMap.setProperty(atom, JS_DupValue(m_ctx, value));

  if (JS_IsFunction(m_ctx, value) && m_eventListenerMap.empty()) {
    std::unique_ptr<NativeString> args_01 = atomToNativeString(m_ctx, atom);
    int32_t type = JS_IsFunction(m_ctx, value) ? UICommand::addEvent : UICommand::removeEvent;
    context()->uiCommandBuffer()->addCommand(m_eventTargetId, type, *args_01, nullptr);
  }
}

JSValue EventTarget::getAttributesEventHandler(JSString* p) {
  char eventType[p->len + 1 - 2];
  memcpy(eventType, &p->u.str8[2], p->len + 1 - 2);
  JSAtom atom = JS_NewAtom(m_ctx, eventType);
  if (!m_eventHandlerMap.contains(atom)) {
    JS_FreeAtom(m_ctx, atom);
    return JS_NULL;
  }

  JSValue handler = JS_DupValue(m_ctx, m_eventHandlerMap.getProperty(atom));
  JS_FreeAtom(m_ctx, atom);
  return handler;
}

JSValue EventTarget::getNativeProperty(const char* prop) {
  std::string method = GetPropertyCallPreFix + std::string(prop);
  getDartMethod()->flushUICommand();
  JSValue result = callNativeMethods(method.c_str(), 0, nullptr);
  return result;
}

// JSValues are stored in this class are no visible to QuickJS GC.
// We needs to gc which JSValues are still holding.
void EventTarget::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  // Trace m_eventListeners.
  m_eventListenerMap.trace(rt, JS_UNDEFINED, mark_func);

  // Trace m_eventHandlers.
  m_eventHandlerMap.trace(rt, JS_UNDEFINED, mark_func);

  // Trace properties.
  m_properties.trace(rt, JS_UNDEFINED, mark_func);
}

void EventTarget::dispose() const {
#if UNIT_TEST
  // Callback to unit test specs before eventTarget finalized.
  if (TEST_getEnv(m_context->uniqueId)->onEventTargetDisposed != nullptr) {
    TEST_getEnv(m_context->uniqueId)->onEventTargetDisposed(this);
  }
#endif

  context()->uiCommandBuffer()->addCommand(m_eventTargetId, UICommand::disposeEventTarget, nullptr, false);
  getDartMethod()->flushUICommand();
  delete nativeEventTarget;
}

void EventTarget::copyNodeProperties(EventTarget* newNode, EventTarget* referenceNode) {
  referenceNode->m_properties.copyWith(&newNode->m_properties);
}

void NativeEventTarget::dispatchEventImpl(int32_t contextId, NativeEventTarget* nativeEventTarget, NativeString* nativeEventType, void* rawEvent, int32_t isCustomEvent) {
  assert_m(nativeEventTarget->instance != nullptr, "NativeEventTarget should have owner");
  EventTarget* eventTarget = nativeEventTarget->instance;

  auto* runtime = ExecutionContext::runtime();

  // Should avoid dispatch event is ctx is invalid.
  if (!isContextValid(contextId)) {
    return;
  }

  // We should avoid trigger event if eventTarget are no long live on heap.
  if (!JS_IsLiveObject(runtime, eventTarget->toQuickJS())) {
    return;
  }

  ExecutionContext* context = eventTarget->context();
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t*>(nativeEventType->string), nativeEventType->length);
  std::string eventType = toUTF8(u16EventType);
  auto* raw = static_cast<RawEvent*>(rawEvent);
  // NativeEvent members are memory aligned corresponding to NativeEvent.
  // So we can reinterpret_cast raw bytes pointer to NativeEvent type directly.
  auto* nativeEvent = reinterpret_cast<NativeEvent*>(raw->bytes);
  Event* event = isCustomEvent == 1 ? CustomEvent::create(context->ctx(), reinterpret_cast<NativeCustomEvent*>(nativeEvent)) : Event::create(context->ctx(), nativeEvent);
  event->nativeEvent->target = eventTarget;
  eventTarget->dispatchEvent(event);
  JS_FreeValue(context->ctx(), event->toQuickJS());
}

}  // namespace kraken
