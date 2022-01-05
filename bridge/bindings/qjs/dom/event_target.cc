/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_target.h"

#include <utility>
#include "bindings/qjs/bom/window.h"
#include "bindings/qjs/dom/text_node.h"
#include "bindings/qjs/qjs_patch.h"
#include "document.h"
#include "element.h"
#include "event.h"
#include "kraken_bridge.h"

namespace kraken::binding::qjs {

static std::atomic<int32_t> globalEventTargetId{0};
std::once_flag kEventTargetInitFlag;
#define GetPropertyCallPreFix "_getProperty_"

void bindEventTarget(std::unique_ptr<ExecutionContext>& context) {
  auto* constructor = EventTarget::instance(context.get());
  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  JS_SetPrototype(context->ctx(), context->global(), constructor->jsObject);
  context->defineGlobalProperty("EventTarget", constructor->jsObject);
}

JSClassID EventTarget::kEventTargetClassId{0};

EventTarget::EventTarget(ExecutionContext* context, const char* name) : HostClass(context, name) {}
EventTarget::EventTarget(ExecutionContext* context) : HostClass(context, "EventTarget") {
  std::call_once(kEventTargetInitFlag, []() { JS_NewClassID(&kEventTargetClassId); });
}

JSValue EventTarget::instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  auto eventTarget = new EventTargetInstance(this, kEventTargetClassId, "EventTarget");
  return eventTarget->jsObject;
}

JSClassID EventTarget::classId() {
  assert_m(false, "classId is not implemented");
  return 0;
}

JSClassID EventTarget::classId(JSValue& value) {
  JSClassID classId = JSValueGetClassId(value);
  return classId;
}

JSValue EventTarget::addEventListener(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: type and listener are required.");
  }

  auto* eventTargetInstance = static_cast<EventTargetInstance*>(JS_GetOpaque(this_val, EventTarget::classId(this_val)));
  if (eventTargetInstance == nullptr) {
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
  if (!eventTargetInstance->m_eventListenerMap.contains(eventType) || eventTargetInstance->m_eventHandlerMap.contains(eventType)) {
    int32_t contextId = eventTargetInstance->prototype()->contextId();

    NativeString args_01{};
    buildUICommandArgs(ctx, eventTypeValue, args_01);

    eventTargetInstance->m_context->uiCommandBuffer()->addCommand(eventTargetInstance->m_eventTargetId, UICommand::addEvent, args_01, nullptr);
  }

  bool success = eventTargetInstance->m_eventListenerMap.add(eventType, JS_DupValue(ctx, callback));
  // Callback didn't saved to eventListenerMap.
  if (!success) {
    JS_FreeAtom(ctx, eventType);
    JS_FreeValue(ctx, callback);
  }

  return JS_UNDEFINED;
}

JSValue EventTarget::removeEventListener(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: at least type and listener are required.");
  }

  auto* eventTargetInstance = static_cast<EventTargetInstance*>(JS_GetOpaque(this_val, EventTarget::classId(this_val)));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue eventTypeValue = argv[0];
  JSValue callback = argv[1];

  if (!JS_IsString(eventTypeValue) || !JS_IsObject(callback) || !JS_IsObject(callback)) {
    return JS_ThrowTypeError(ctx, "Failed to removeEventListener: eventName should be an string.");
  }

  JSAtom eventType = JS_ValueToAtom(ctx, eventTypeValue);
  auto& eventHandlers = eventTargetInstance->m_eventListenerMap;

  if (!eventTargetInstance->m_eventListenerMap.contains(eventType)) {
    JS_FreeAtom(ctx, eventType);
    return JS_UNDEFINED;
  }

  if (eventHandlers.remove(eventType, callback)) {
    JS_FreeAtom(ctx, eventType);
    JS_FreeValue(ctx, callback);
  }

  if (eventHandlers.empty() && eventTargetInstance->m_eventHandlerMap.contains(eventType)) {
    // Dart needs to be notified for handles is empty.
    int32_t contextId = eventTargetInstance->prototype()->contextId();

    NativeString args_01{};
    buildUICommandArgs(ctx, eventTypeValue, args_01);

    eventTargetInstance->m_context->uiCommandBuffer()->addCommand(eventTargetInstance->m_eventTargetId, UICommand::removeEvent, args_01, nullptr);
  }

  JS_FreeAtom(ctx, eventType);
  return JS_UNDEFINED;
}

JSValue EventTarget::dispatchEvent(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  if (argc != 1) {
    return JS_ThrowTypeError(ctx, "Failed to dispatchEvent: first arguments should be an event object");
  }

  auto* eventTargetInstance = static_cast<EventTargetInstance*>(JS_GetOpaque(this_val, EventTarget::classId(this_val)));
  if (eventTargetInstance == nullptr) {
    return JS_ThrowTypeError(ctx, "Failed to addEventListener: this is not an EventTarget object.");
  }

  JSValue eventValue = argv[0];
  auto eventInstance = reinterpret_cast<EventInstance*>(JS_GetOpaque(eventValue, EventTarget::classId(eventValue)));
  return JS_NewBool(ctx, eventTargetInstance->dispatchEvent(eventInstance));
}

bool EventTargetInstance::dispatchEvent(EventInstance* event) {
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t*>(event->nativeEvent->type->string), event->nativeEvent->type->length);
  std::string eventType = toUTF8(u16EventType);

  // protect this util event trigger finished.
  JS_DupValue(m_ctx, jsObject);

  internalDispatchEvent(event);

  // Bubble event to root event target.
  if (event->nativeEvent->bubbles == 1 && !event->propagationStopped()) {
    auto node = reinterpret_cast<NodeInstance*>(this);
    auto* parent = static_cast<NodeInstance*>(JS_GetOpaque(node->parentNode, Node::classId(node->parentNode)));

    if (parent != nullptr) {
      parent->dispatchEvent(event);
    } else {
      // Window does not inherit from Node, so it is not in the Node tree and needs to continue passing to the Window when it bubbles to Document.
      JSValue globalObjectValue = JS_GetGlobalObject(m_context->ctx());
      auto* window = static_cast<WindowInstance*>(JS_GetOpaque(globalObjectValue, Window::classId()));
      window->internalDispatchEvent(event);
      JS_FreeValue(m_ctx, globalObjectValue);
    }
  }

  JS_FreeValue(m_ctx, jsObject);

  return event->cancelled();
}

bool EventTargetInstance::internalDispatchEvent(EventInstance* eventInstance) {
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t*>(eventInstance->nativeEvent->type->string), eventInstance->nativeEvent->type->length);
  std::string eventTypeStr = toUTF8(u16EventType);
  JSAtom eventType = JS_NewAtom(m_ctx, eventTypeStr.c_str());

  // Modify the currentTarget to this.
  eventInstance->nativeEvent->currentTarget = this;

  // Dispatch event listeners writen by addEventListener
  auto _dispatchEvent = [&eventInstance, this](JSValue handler) {
    if (!JS_IsFunction(m_ctx, handler))
      return;

    if (eventInstance->propagationImmediatelyStopped())
      return;

    /* 'handler' might be destroyed when calling itself (if it frees the
     handler), so must take extra care */
    JS_DupValue(m_ctx, handler);

    // The third params `thisObject` to null equals global object.
    JSValue returnedValue = JS_Call(m_ctx, handler, JS_NULL, 1, &eventInstance->jsObject);

    JS_FreeValue(m_ctx, handler);
    m_context->handleException(&returnedValue);
    m_context->drainPendingPromiseJobs();
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
      auto _dispatchErrorEvent = [&eventInstance, this, eventTypeStr](JSValue handler) {
        JSValue error = JS_GetPropertyStr(m_ctx, eventInstance->jsObject, "error");
        JSValue messageValue = JS_GetPropertyStr(m_ctx, error, "message");
        JSValue lineNumberValue = JS_GetPropertyStr(m_ctx, error, "lineNumber");
        JSValue fileNameValue = JS_GetPropertyStr(m_ctx, error, "fileName");
        JSValue columnValue = JS_NewUint32(m_ctx, 0);

        JSValue args[]{messageValue, fileNameValue, lineNumberValue, columnValue, error};
        JS_Call(m_ctx, handler, eventInstance->jsObject, 5, args);
        m_context->drainPendingPromiseJobs();

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
  return eventInstance->cancelled();
}

EventTargetInstance::EventTargetInstance(EventTarget* eventTarget, JSClassID classId, JSClassExoticMethods& exoticMethods, std::string name)
    : Instance(eventTarget, name, &exoticMethods, classId, finalize) {
  m_eventTargetId = globalEventTargetId++;
}

EventTargetInstance::EventTargetInstance(EventTarget* eventTarget, JSClassID classId, std::string name) : Instance(eventTarget, std::move(name), nullptr, classId, finalize) {
  m_eventTargetId = globalEventTargetId++;
}

EventTargetInstance::EventTargetInstance(EventTarget* eventTarget, JSClassID classId, std::string name, int64_t eventTargetId)
    : Instance(eventTarget, std::move(name), nullptr, classId, finalize), m_eventTargetId(eventTargetId) {}

JSClassID EventTargetInstance::classId() {
  assert_m(false, "classId is not implemented");
  return 0;
}

EventTargetInstance::~EventTargetInstance() {
  m_context->uiCommandBuffer()->addCommand(m_eventTargetId, UICommand::disposeEventTarget, nullptr, false);
  getDartMethod()->flushUICommand();
  delete nativeEventTarget;
}

int EventTargetInstance::hasProperty(JSContext* ctx, JSValue obj, JSAtom atom) {
  auto* eventTarget = static_cast<EventTargetInstance*>(JS_GetOpaque(obj, JSValueGetClassId(obj)));
  auto* prototype = static_cast<EventTarget*>(eventTarget->prototype());

  if (JS_HasProperty(ctx, prototype->m_prototypeObject, atom))
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

JSValue EventTargetInstance::getProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  auto* eventTarget = static_cast<EventTargetInstance*>(JS_GetOpaque(obj, JSValueGetClassId(obj)));
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

int EventTargetInstance::setProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  auto* eventTarget = static_cast<EventTargetInstance*>(JS_GetOpaque(obj, JSValueGetClassId(obj)));
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
      eventTarget->m_context->uiCommandBuffer()->addCommand(eventTarget->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
    }
  }

  JS_FreeValue(ctx, atomString);

  return 0;
}

int EventTargetInstance::deleteProperty(JSContext* ctx, JSValue obj, JSAtom prop) {
  return 0;
}

JSValue EventTargetInstance::callNativeMethods(const char* method, int32_t argc, NativeValue* argv) {
  if (nativeEventTarget->callNativeMethods == nullptr) {
    return JS_ThrowTypeError(m_ctx, "Failed to call native dart methods: callNativeMethods not initialized.");
  }

  std::u16string methodString;
  fromUTF8(method, methodString);

  NativeString m{reinterpret_cast<const uint16_t*>(methodString.c_str()), static_cast<uint32_t>(methodString.size())};

  NativeValue nativeValue{};
  nativeEventTarget->callNativeMethods(nativeEventTarget, &nativeValue, &m, argc, argv);
  JSValue returnValue = nativeValueToJSValue(m_context, nativeValue);
  return returnValue;
}

void EventTargetInstance::setAttributesEventHandler(JSString* p, JSValue value) {
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
    int32_t contextId = m_context->getContextId();
    std::unique_ptr<NativeString> args_01 = atomToNativeString(m_ctx, atom);
    int32_t type = JS_IsFunction(m_ctx, value) ? UICommand::addEvent : UICommand::removeEvent;
    m_context->uiCommandBuffer()->addCommand(m_eventTargetId, type, *args_01, nullptr);
  }
}

JSValue EventTargetInstance::getAttributesEventHandler(JSString* p) {
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

void EventTargetInstance::finalize(JSRuntime* rt, JSValue val) {
  auto* eventTarget = static_cast<EventTargetInstance*>(JS_GetOpaque(val, EventTarget::classId(val)));
  delete eventTarget;
}

JSValue EventTargetInstance::getNativeProperty(const char* prop) {
  std::string method = GetPropertyCallPreFix + std::string(prop);
  getDartMethod()->flushUICommand();
  JSValue result = callNativeMethods(method.c_str(), 0, nullptr);
  return result;
}

// JSValues are stored in this class are no visible to QuickJS GC.
// We needs to gc which JSValues are still holding.
void EventTargetInstance::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  // Trace m_eventListeners.
  m_eventListenerMap.trace(rt, JS_UNDEFINED, mark_func);

  // Trace m_eventHandlers.
  m_eventHandlerMap.trace(rt, JS_UNDEFINED, mark_func);

  // Trace properties.
  m_properties.trace(rt, JS_UNDEFINED, mark_func);
}

void EventTargetInstance::copyNodeProperties(EventTargetInstance* newNode, EventTargetInstance* referenceNode) {
  referenceNode->m_properties.copyWith(&newNode->m_properties);
}

void NativeEventTarget::dispatchEventImpl(NativeEventTarget* nativeEventTarget, NativeString* nativeEventType, void* rawEvent, int32_t isCustomEvent) {
  assert_m(nativeEventTarget->instance != nullptr, "NativeEventTarget should have owner");
  EventTargetInstance* eventTargetInstance = nativeEventTarget->instance;
  ExecutionContext* context = eventTargetInstance->context();
  std::u16string u16EventType = std::u16string(reinterpret_cast<const char16_t*>(nativeEventType->string), nativeEventType->length);
  std::string eventType = toUTF8(u16EventType);
  auto* raw = static_cast<RawEvent*>(rawEvent);
  // NativeEvent members are memory aligned corresponding to NativeEvent.
  // So we can reinterpret_cast raw bytes pointer to NativeEvent type directly.
  auto* nativeEvent = reinterpret_cast<NativeEvent*>(raw->bytes);
  EventInstance* eventInstance = Event::buildEventInstance(eventType, context, nativeEvent, isCustomEvent == 1);
  eventInstance->nativeEvent->target = eventTargetInstance;
  eventTargetInstance->dispatchEvent(eventInstance);
  JS_FreeValue(context->ctx(), eventInstance->jsObject);
}

}  // namespace kraken::binding::qjs
