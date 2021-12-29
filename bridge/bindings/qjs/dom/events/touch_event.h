/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TOUCH_EVENT_H
#define KRAKENBRIDGE_TOUCH_EVENT_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {

void bindTouchEvent(std::unique_ptr<ExecutionContext>& context);

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
  explicit Touch(ExecutionContext* context, NativeTouch* nativePtr);

 private:
  NativeTouch* m_nativeTouch{nullptr};
  DEFINE_READONLY_PROPERTY(identifier);
  DEFINE_READONLY_PROPERTY(target);
  DEFINE_READONLY_PROPERTY(clientX);
  DEFINE_READONLY_PROPERTY(clientY);
  DEFINE_READONLY_PROPERTY(screenX);
  DEFINE_READONLY_PROPERTY(screenY);
  DEFINE_READONLY_PROPERTY(pageX);
  DEFINE_READONLY_PROPERTY(pageY);
  DEFINE_READONLY_PROPERTY(radiusX);
  DEFINE_READONLY_PROPERTY(radiusY);
  DEFINE_READONLY_PROPERTY(rotationAngle);
  DEFINE_READONLY_PROPERTY(force);
  DEFINE_READONLY_PROPERTY(altitudeAngle);
  DEFINE_READONLY_PROPERTY(azimuthAngle);
  DEFINE_READONLY_PROPERTY(touchType);
};

class TouchList : public ExoticHostObject {
 public:
  TouchList() = delete;
  explicit TouchList(ExecutionContext* context, NativeTouch** touches, int64_t length);

  JSValue getProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);
  int setProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);

 private:
  DEFINE_PROPERTY(length);
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
class TouchEventInstance;
class TouchEvent : public Event {
 public:
  TouchEvent() = delete;
  explicit TouchEvent(ExecutionContext* context);
  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  OBJECT_INSTANCE(TouchEvent);

 private:
  DEFINE_PROTOTYPE_READONLY_PROPERTY(touches);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(targetTouches);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(changedTouches);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(altKey);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(metaKey);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(ctrlKey);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(shiftKey);

  friend TouchEventInstance;
};

class TouchEventInstance : public EventInstance {
 public:
  TouchEventInstance() = delete;
  explicit TouchEventInstance(TouchEvent* event, NativeEvent* nativeEvent);

 private:
  friend TouchEvent;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_TOUCH_EVENTT_H
