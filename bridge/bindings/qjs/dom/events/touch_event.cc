/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "touch_event.h"
#include "bindings/qjs/qjs_patch.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {

void bindTouchEvent(std::unique_ptr<JSContext>& context) {
  auto* constructor = TouchEvent::instance(context.get());
  context->defineGlobalProperty("TouchEvent", constructor->jsObject);
}

TouchList::TouchList(JSContext* context, NativeTouch** touches, int64_t length) : ExoticHostObject(context, "TouchList"), m_touches(touches), _length(length) {}

JSValue TouchList::getProperty(QjsContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  std::string key = jsAtomToStdString(ctx, atom);
  if (isNumberIndex(key)) {
    size_t index = std::stoi(key);
    return (new Touch(m_context, m_touches[index]))->jsObject;
  }

  return JS_NULL;
}

int TouchList::setProperty(QjsContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  return 0;
}

IMPL_PROPERTY_GETTER(TouchList, length)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* touchList = static_cast<TouchList*>(JS_GetOpaque(this_val, JSContext::kHostExoticObjectClassId));
  return JS_NewUint32(ctx, touchList->_length);
}
IMPL_PROPERTY_SETTER(TouchList, length)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  return JS_NULL;
}

Touch::Touch(JSContext* context, NativeTouch* nativeTouch) : HostObject(context, "Touch"), m_nativeTouch(nativeTouch) {}

IMPL_PROPERTY_GETTER(Touch, identifier)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewUint32(ctx, object->m_nativeTouch->identifier);
}
IMPL_PROPERTY_GETTER(Touch, target)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  auto* eventTarget = object->m_nativeTouch->target;
  return JS_DupValue(ctx, eventTarget->instance->jsObject);
}
IMPL_PROPERTY_GETTER(Touch, clientX)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->clientX);
}
IMPL_PROPERTY_GETTER(Touch, clientY)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->clientY);
}
IMPL_PROPERTY_GETTER(Touch, screenX)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->screenX);
}
IMPL_PROPERTY_GETTER(Touch, screenY)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->screenY);
}
IMPL_PROPERTY_GETTER(Touch, pageX)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->pageX);
}
IMPL_PROPERTY_GETTER(Touch, pageY)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->pageY);
}
IMPL_PROPERTY_GETTER(Touch, radiusX)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->radiusX);
}
IMPL_PROPERTY_GETTER(Touch, radiusY)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->radiusY);
}
IMPL_PROPERTY_GETTER(Touch, rotationAngle)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->rotationAngle);
}
IMPL_PROPERTY_GETTER(Touch, force)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->force);
}
IMPL_PROPERTY_GETTER(Touch, altitudeAngle)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->altitudeAngle);
}
IMPL_PROPERTY_GETTER(Touch, azimuthAngle)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewFloat64(ctx, object->m_nativeTouch->azimuthAngle);
}
IMPL_PROPERTY_GETTER(Touch, touchType)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* object = static_cast<Touch*>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewUint32(ctx, object->m_nativeTouch->touchType);
}

TouchEvent::TouchEvent(JSContext* context) : Event(context) {}

JSValue TouchEvent::instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) {
  if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to construct 'TouchEvent': 1 argument required, but only 0 present.");
  }

  JSValue eventTypeValue = argv[0];
  JSValue eventInit = JS_NULL;

  if (argc == 2) {
    eventInit = argv[1];
  }

  auto* nativeEvent = new NativeTouchEvent();
  nativeEvent->nativeEvent.type = jsValueToNativeString(ctx, eventTypeValue).release();

  if (JS_IsObject(eventInit)) {
    JSAtom touchesAtom = JS_NewAtom(m_ctx, "touches");
    JSAtom targetTouchesAtom = JS_NewAtom(m_ctx, "targetTouches");
    JSAtom changedTouchesAtom = JS_NewAtom(m_ctx, "changedTouches");
    JSAtom altKeyAtom = JS_NewAtom(m_ctx, "altKey");
    JSAtom metaKeyAtom = JS_NewAtom(m_ctx, "metaKey");
    JSAtom ctrlKeyAtom = JS_NewAtom(m_ctx, "ctrlKey");
    JSAtom shiftKeyAtom = JS_NewAtom(m_ctx, "shiftKey");
    auto* ne = reinterpret_cast<NativeTouchEvent*>(nativeEvent);

    if (JS_HasProperty(m_ctx, eventInit, touchesAtom)) {
      JSValue touchesValue = JS_GetProperty(ctx, eventInit, touchesAtom);
      if (JS_IsArray(ctx, touchesValue)) {
        uint32_t length;
        JSValue lengthValue = JS_GetPropertyStr(ctx, touchesValue, "length");
        JS_ToUint32(ctx, &length, lengthValue);

        ne->touches = new NativeTouch*[length];
        ne->touchLength = length;
        for (int i = 0; i < length; i++) {
          JSValue v = JS_GetPropertyUint32(ctx, touchesValue, i);
          if (JS_IsInstanceOf(ctx, v, TouchEvent::instance(m_context)->jsObject)) {
            ne->touches[i] = static_cast<NativeTouch*>(JS_GetOpaque(v, JSContext::kHostObjectClassId));
          }
        }
      }
    }
    if (JS_HasProperty(m_ctx, eventInit, targetTouchesAtom)) {
      JSValue targetTouchesValue = JS_GetProperty(ctx, eventInit, targetTouchesAtom);
      if (JS_IsArray(ctx, targetTouchesValue)) {
        uint32_t length;
        JSValue lengthValue = JS_GetPropertyStr(ctx, targetTouchesValue, "length");
        JS_ToUint32(ctx, &length, lengthValue);

        ne->targetTouches = new NativeTouch*[length];
        ne->targetTouchesLength = length;
        for (int i = 0; i < length; i++) {
          JSValue v = JS_GetPropertyUint32(ctx, targetTouchesValue, i);
          if (JS_IsInstanceOf(ctx, v, TouchEvent::instance(m_context)->jsObject)) {
            ne->targetTouches[i] = static_cast<NativeTouch*>(JS_GetOpaque(v, JSContext::kHostObjectClassId));
          }
        }
      }
    }
    if (JS_HasProperty(m_ctx, eventInit, changedTouchesAtom)) {
      JSValue changedTouchesValue = JS_GetProperty(ctx, eventInit, changedTouchesAtom);
      if (JS_IsArray(ctx, changedTouchesValue)) {
        uint32_t length;
        JSValue lengthValue = JS_GetPropertyStr(ctx, changedTouchesValue, "length");
        JS_ToUint32(ctx, &length, lengthValue);

        ne->changedTouches = new NativeTouch*[length];
        ne->changedTouchesLength = length;
        for (int i = 0; i < length; i++) {
          JSValue v = JS_GetPropertyUint32(ctx, changedTouchesValue, i);
          if (JS_IsInstanceOf(ctx, v, TouchEvent::instance(m_context)->jsObject)) {
            ne->changedTouches[i] = static_cast<NativeTouch*>(JS_GetOpaque(v, JSContext::kHostObjectClassId));
          }
        }
      }
    }
    if (JS_HasProperty(m_ctx, eventInit, altKeyAtom)) {
      ne->altKey = JS_ToBool(m_ctx, JS_GetProperty(m_ctx, eventInit, altKeyAtom)) ? 1 : 0;
    }
    if (JS_HasProperty(m_ctx, eventInit, metaKeyAtom)) {
      ne->metaKey = JS_ToBool(m_ctx, JS_GetProperty(m_ctx, eventInit, metaKeyAtom)) ? 1 : 0;
    }
    if (JS_HasProperty(m_ctx, eventInit, ctrlKeyAtom)) {
      ne->ctrlKey = JS_ToBool(m_ctx, JS_GetProperty(m_ctx, eventInit, ctrlKeyAtom)) ? 1 : 0;
    }
    if (JS_HasProperty(m_ctx, eventInit, shiftKeyAtom)) {
      ne->shiftKey = JS_ToBool(m_ctx, JS_GetProperty(m_ctx, eventInit, shiftKeyAtom)) ? 1 : 0;
    }

    JS_FreeAtom(m_ctx, touchesAtom);
    JS_FreeAtom(m_ctx, targetTouchesAtom);
    JS_FreeAtom(m_ctx, changedTouchesAtom);
    JS_FreeAtom(m_ctx, altKeyAtom);
    JS_FreeAtom(m_ctx, metaKeyAtom);
    JS_FreeAtom(m_ctx, ctrlKeyAtom);
    JS_FreeAtom(m_ctx, shiftKeyAtom);
  }

  auto event = new TouchEventInstance(this, reinterpret_cast<NativeEvent*>(nativeEvent));
  return event->jsObject;
}
IMPL_PROPERTY_GETTER(TouchEvent, touches)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<TouchEventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  auto* nativeEvent = reinterpret_cast<NativeTouchEvent*>(event->nativeEvent);
  auto* touchList = new TouchList(event->m_context, nativeEvent->touches, nativeEvent->touchLength);
  return touchList->jsObject;
}

IMPL_PROPERTY_GETTER(TouchEvent, targetTouches)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<TouchEventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  auto* nativeEvent = reinterpret_cast<NativeTouchEvent*>(event->nativeEvent);
  auto* targetTouchList = new TouchList(event->m_context, nativeEvent->targetTouches, nativeEvent->targetTouchesLength);
  return targetTouchList->jsObject;
}

IMPL_PROPERTY_GETTER(TouchEvent, changedTouches)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<TouchEventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  auto* nativeEvent = reinterpret_cast<NativeTouchEvent*>(event->nativeEvent);
  auto* changedTouchList = new TouchList(event->m_context, nativeEvent->changedTouches, nativeEvent->changedTouchesLength);
  return changedTouchList->jsObject;
}

IMPL_PROPERTY_GETTER(TouchEvent, altKey)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<TouchEventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  auto* nativeEvent = reinterpret_cast<NativeTouchEvent*>(event->nativeEvent);
  return JS_NewBool(ctx, nativeEvent->altKey ? 1 : 0);
}

IMPL_PROPERTY_GETTER(TouchEvent, metaKey)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<TouchEventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  auto* nativeEvent = reinterpret_cast<NativeTouchEvent*>(event->nativeEvent);
  return JS_NewBool(ctx, nativeEvent->metaKey ? 1 : 0);
}

IMPL_PROPERTY_GETTER(TouchEvent, ctrlKey)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<TouchEventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  auto* nativeEvent = reinterpret_cast<NativeTouchEvent*>(event->nativeEvent);
  return JS_NewBool(ctx, nativeEvent->ctrlKey ? 1 : 0);
}

IMPL_PROPERTY_GETTER(TouchEvent, shiftKey)(QjsContext* ctx, JSValue this_val, int argc, JSValue* argv) {
  auto* event = static_cast<TouchEventInstance*>(JS_GetOpaque(this_val, Event::kEventClassID));
  auto* nativeEvent = reinterpret_cast<NativeTouchEvent*>(event->nativeEvent);
  return JS_NewBool(ctx, nativeEvent->shiftKey ? 1 : 0);
}

TouchEventInstance::TouchEventInstance(TouchEvent* event, NativeEvent* nativeEvent) : EventInstance(event, nativeEvent) {}

}  // namespace kraken::binding::qjs
