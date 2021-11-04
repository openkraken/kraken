/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TOUCH_EVENT_H
#define KRAKENBRIDGE_TOUCH_EVENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {

void bindTouchEvent(std::unique_ptr<JSContext>& context);

struct NativeTouch {
  int64_t identifier;
  NativeEventTarget* target;
  double clientX;
  double clientY;
  double screenX;
  double screenY;
  double pageX;
  double pageY;
  double radiusX;
  double radiusY;
  double rotationAngle;
  double force;
  double altitudeAngle;
  double azimuthAngle;
  int64_t touchType;
};

class Touch : public HostObject {
 public:
  Touch() = delete;
  explicit Touch(JSContext* context, NativeTouch* nativePtr);

 private:
  NativeTouch* m_nativeTouch{nullptr};
  DEFINE_HOST_OBJECT_PROPERTY(15, identifier, target, clientX, clientY, screenX, screenY, pageX, pageY, radiusX, radiusY, rotationAngle, force, altitudeAngle, azimuthAngle, touchType)
};

class TouchList : public ExoticHostObject {
 public:
  TouchList() = delete;
  explicit TouchList(JSContext* context, NativeTouch** touches, int64_t length);

  JSValue getProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);
  int setProperty(QjsContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);

 private:
  DEFINE_HOST_OBJECT_PROPERTY(1, length)
  NativeTouch** m_touches{nullptr};
  int64_t _length;
};

struct NativeTouchEvent {
  NativeEvent nativeEvent;

  NativeTouch** touches;
  int64_t touchLength;
  NativeTouch** targetTouches;
  int64_t targetTouchesLength;
  NativeTouch** changedTouches;
  int64_t changedTouchesLength;

  int64_t altKey;
  int64_t metaKey;
  int64_t ctrlKey;
  int64_t shiftKey;
};
class TouchEvent : public Event {
 public:
  TouchEvent() = delete;
  explicit TouchEvent(JSContext* context);
  JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  OBJECT_INSTANCE(TouchEvent);

 private:
};
class TouchEventInstance : public EventInstance {
 public:
  TouchEventInstance() = delete;
  explicit TouchEventInstance(TouchEvent* event, NativeEvent* nativeEvent);

 private:
  DEFINE_HOST_CLASS_PROPERTY(7, touches, targetTouches, changedTouches, altKey, metaKey, ctrlKey, shiftKey)
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_TOUCH_EVENTT_H
