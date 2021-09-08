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
#include "bindings/qjs/dom/text_node.h"

namespace kraken::binding::qjs {

static std::atomic<int32_t> globalEventTargetId{0};
std::once_flag kEventTargetInitFlag;

void bindEventTarget(std::unique_ptr<JSContext> &context) {
  auto *constructor = EventTarget::instance(context.get());
  // Set globalThis and Window's prototype to EventTarget's prototype to support EventTarget methods in global.
  JS_SetPrototype(context->ctx(), context->global(), constructor->classObject);
  context->defineGlobalProperty("EventTarget", constructor->classObject);
}

JSClassID EventTarget::kEventTargetClassId {0};

EventTarget::EventTarget(JSContext *context, const char *name) : HostClass(context, name) {
}
EventTarget::EventTarget(JSContext *context) : HostClass(context, "EventTarget") {
  std::call_once(kEventTargetInitFlag, []() {
    JS_NewClassID(&kEventTargetClassId);
  });
}

OBJECT_INSTANCE_IMPL(EventTarget);

JSValue EventTarget::instanceConstructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  auto eventTarget = new EventTargetInstance(this, kEventTargetClassId, "EventTarget");
  return eventTarget->instanceObject;
}

JSClassID EventTarget::classId() {
  assert_m(false, "classId is not implemented");
  return 0;
}

JSClassID EventTarget::classId(JSValue &value) {
  JSClassID classId = JSValueGetClassId(value);
  return classId;
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

  JSAtom eventTypeAtom = JS_ValueToAtom(ctx, eventTypeValue);

  // Init list.
  if (eventTargetInstance->_eventHandlers.count(eventTypeAtom) == 0) {
    JS_DupAtom(ctx, eventTypeAtom);
    auto *atomJob = new AtomJob{eventTypeAtom};
    list_add_tail(&atomJob->link, &eventTargetInstance->m_context->atom_job_list);
    eventTargetInstance->_eventHandlers[eventTypeAtom] = std::vector<JSValue>();
  }

  // Dart needs to be notified for the first registration event.
  if (eventTargetInstance->_eventHandlers[eventTypeAtom].empty() ||
      eventTargetInstance->_propertyEventHandler.count(eventTypeAtom) > 0) {
    int32_t contextId = eventTargetInstance->prototype()->contextId();

    NativeString args_01{};
    buildUICommandArgs(ctx, eventTypeValue, args_01);

    foundation::UICommandBuffer::instance(contextId)->addCommand(eventTargetInstance->eventTargetId,
                                                                 UICommand::addEvent, args_01, nullptr);
  }

  std::vector<JSValue> &handlers = eventTargetInstance->_eventHandlers[eventTypeAtom];
  JSValue newCallback = JS_DupValue(ctx, callback);

  // Create strong reference between callback and eventTargetObject.
  // So gc can mark this object and recycle it.
  std::string privateKey = "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(callback)));
  JS_DefinePropertyValueStr(ctx, eventTargetInstance->instanceObject, privateKey.c_str(), newCallback, JS_PROP_NORMAL);

  handlers.push_back(newCallback);
  JS_FreeAtom(ctx, eventTypeAtom);

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

  JSAtom eventTypeAtom = JS_ValueToAtom(ctx, eventTypeValue);

  if (eventTargetInstance->_eventHandlers.count(eventTypeAtom) == 0) {
    JS_FreeAtom(ctx, eventTypeAtom);
    return JS_UNDEFINED;
  }

  std::vector<JSValue> &handlers = eventTargetInstance->_eventHandlers[eventTypeAtom];
  std::string privateKey = "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(callback)));
  JSAtom privateKeyAtom = JS_NewAtom(ctx, privateKey.c_str());
  JS_DeleteProperty(ctx, eventTargetInstance->instanceObject, privateKeyAtom, 0);
  JS_FreeAtom(ctx, privateKeyAtom);

  handlers.erase(std::remove_if(handlers.begin(), handlers.end(), [callback](JSValue function) {
    if (JS_VALUE_GET_PTR(function) == JS_VALUE_GET_PTR(callback)) {
      return true;
    }
    return false;
  }), handlers.end());

  if (handlers.empty() && eventTargetInstance->_propertyEventHandler.count(eventTypeAtom) > 0) {
    // Dart needs to be notified for handles is empty.
    int32_t contextId = eventTargetInstance->prototype()->contextId();

    NativeString args_01{};
    buildUICommandArgs(ctx, eventTypeValue, args_01);

    foundation::UICommandBuffer::instance(contextId)->addCommand(eventTargetInstance->eventTargetId,
                                                                 UICommand::removeEvent, args_01, nullptr);
  }

  JS_FreeAtom(ctx, eventTypeAtom);
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
  JSAtom eventTypeAtom = JS_NewAtom(m_ctx, eventType.c_str());

  // Dispatch event listeners writen by addEventListener
  auto _dispatchEvent = [&eventInstance, this](JSValue &handler) {
    if (eventInstance->propagationImmediatelyStopped()) return;
    // The third params `thisObject` to null equals global object.
    JSValue returnedValue = JS_Call(m_ctx, handler, JS_NULL, 1, &eventInstance->instanceObject);
    m_context->handleException(&returnedValue);
    JS_FreeValue(m_ctx, returnedValue);
  };

  if (_eventHandlers.count(eventTypeAtom) > 0) {
    auto stack = _eventHandlers[eventTypeAtom];

    for (auto &handler : stack) {
      _dispatchEvent(handler);
    }
  }

  // Dispatch event listener white by 'on' prefix property.
  if (_propertyEventHandler.count(eventTypeAtom) > 0) {
    if (eventType == "error") {
      auto _dispatchErrorEvent = [&eventInstance, this, eventType](JSValue &handler) {
        JSValue error = JS_GetPropertyStr(m_ctx, eventInstance->instanceObject, "error");
        JSValue messageValue = JS_GetPropertyStr(m_ctx, error, "message");
        JSValue lineNumberValue = JS_GetPropertyStr(m_ctx, error, "lineNumber");
        JSValue fileNameValue = JS_GetPropertyStr(m_ctx, error, "fileName");
        JSValue columnValue = JS_NewUint32(m_ctx, 0);

        JSValue args[] {
          messageValue,
          fileNameValue,
          lineNumberValue,
          columnValue,
          error
        };
        JS_Call(m_ctx, handler, eventInstance->instanceObject, 5, args);

        JS_FreeValue(m_ctx, messageValue);
        JS_FreeValue(m_ctx, fileNameValue);
        JS_FreeValue(m_ctx, lineNumberValue);
        JS_FreeValue(m_ctx, columnValue);
      };
      _dispatchErrorEvent(_propertyEventHandler[eventTypeAtom]);
    } else {
      _dispatchEvent(_propertyEventHandler[eventTypeAtom]);
    }
  }

  JS_FreeAtom(m_ctx, eventTypeAtom);

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

int EventTargetInstance::hasProperty(QjsContext *ctx, JSValue obj, JSAtom atom) {
  auto *eventTarget = static_cast<EventTargetInstance *>(JS_GetOpaque(obj, JSValueGetClassId(obj)));
  auto *prototype = static_cast<EventTarget *>(eventTarget->prototype());

  if (JS_HasProperty(ctx, prototype->m_prototypeObject, atom)) return true;

  JSValue atomString = JS_AtomToString(ctx, atom);
  JSString *p = JS_VALUE_GET_STRING(atomString);
  // There are still one reference_count in atom. It's safe to free here.
  JS_FreeValue(ctx, atomString);

  if (!p->is_wide_char && p->u.str8[0] == 'o' && p->u.str8[1] == 'n') {
    return !JS_IsNull(eventTarget->getPropertyHandler(atom));
  }

  return eventTarget->m_properties.count(atom) >= 0;
}

JSValue EventTargetInstance::getProperty(QjsContext *ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  auto *eventTarget = static_cast<EventTargetInstance *>(JS_GetOpaque(obj, JSValueGetClassId(obj)));
  JSValue prototype = JS_GetPrototype(ctx, eventTarget->instanceObject);
  if (JS_HasProperty(ctx, prototype, atom)) {
    return JS_GetPropertyInternal(ctx, prototype, atom, eventTarget->instanceObject, 0);
  }

  JSValue atomString = JS_AtomToString(ctx, atom);
  JSString *p = JS_VALUE_GET_STRING(atomString);
  // There are still one reference_count in atom. It's safe to free here.
  JS_FreeValue(ctx, atomString);

  if (!p->is_wide_char && p->u.str8[0] == 'o' && p->u.str8[1] == 'n') {
    return eventTarget->getPropertyHandler(atom);
  }

  return JS_DupValue(ctx, eventTarget->m_properties[atom]);
}

int EventTargetInstance::setProperty(QjsContext *ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  auto *eventTarget = static_cast<EventTargetInstance *>(JS_GetOpaque(obj, JSValueGetClassId(obj)));

  JSValue atomString = JS_AtomToString(ctx, atom);
  JSString *p = JS_VALUE_GET_STRING(atomString);

  if (!p->is_wide_char && p->u.str8[0] == 'o' && p->u.str8[1] == 'n') {
    char eventType[p->len + 1 - 2];
    memcpy(eventType, &p->u.str8[2], p->len + 1 - 2);
    eventTarget->setPropertyHandler(eventType, value);
  } else {
    // Increase one reference count for atom to hold this atom value until eventTarget disposed.
    JS_DupAtom(ctx, atom);
    JSValue newValue = JS_DupValue(ctx, value);
    eventTarget->m_properties[atom] = newValue;

    // Create strong reference and gc can find it.
    std::string privateKey = "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(newValue)));
    JS_DefinePropertyValueStr(ctx, eventTarget->instanceObject, privateKey.c_str(), newValue, JS_PROP_NORMAL);
  }

  JS_FreeValue(ctx, atomString);

  return 0;
}

int EventTargetInstance::deleteProperty(QjsContext *ctx, JSValue obj, JSAtom prop) {
  return 0;
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

void EventTargetInstance::setPropertyHandler(const char* eventType, JSValue value) {
  JSAtom atom = JS_NewAtom(m_ctx, eventType);
  auto *atomJob = new AtomJob{atom};
  list_add_tail(&atomJob->link, &m_context->atom_job_list);

 // We need to remove previous eventHandler when setting new eventHandler with same eventType.
  if (_propertyEventHandler.count(atom) > 0) {
    JSValue callback = _propertyEventHandler[atom];
    std::string privateKey = "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(callback)));
    JSAtom privateKeyAtom = JS_NewAtom(m_ctx, privateKey.c_str());
    JS_DeleteProperty(m_ctx, instanceObject, privateKeyAtom, 0);
    JS_FreeAtom(m_ctx, privateKeyAtom);
    _propertyEventHandler.erase(atom);
  }

  // When evaluate scripts like 'element.onclick = null', we needs to remove the event handlers callbacks
  if (JS_IsNull(value)) {
    JS_FreeAtom(m_ctx, atom);
    list_del(&atomJob->link);
    return;
  }

  // Create strong reference between callback and eventTargetObject.
  // So gc can mark this object and recycle it.
  JSValue newCallback = JS_DupValue(m_ctx, value);
  std::string privateKey = "_" + std::to_string(reinterpret_cast<int64_t>(JS_VALUE_GET_PTR(newCallback)));
  JS_DefinePropertyValueStr(m_ctx, instanceObject, privateKey.c_str(), newCallback, JS_PROP_NORMAL);

  _propertyEventHandler[atom] = newCallback;

  if (_eventHandlers.empty()) {
    int32_t contextId = m_context->getContextId();
    NativeString *args_01 = atomToNativeString(m_ctx, atom);
    int32_t type = JS_IsFunction(m_ctx, value) ? UICommand::addEvent : UICommand::removeEvent;
    foundation::UICommandBuffer::instance(contextId)->addCommand(eventTargetId, type, *args_01, nullptr);
  }
}

JSValue EventTargetInstance::getPropertyHandler(JSAtom atom) {
  if (_propertyEventHandler.count(atom) == 0) {
    return JS_NULL;
  }
  return JS_DupValue(m_ctx, _propertyEventHandler[atom]);
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
