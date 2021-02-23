/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TOUCH_EVENT_H
#define KRAKENBRIDGE_TOUCH_EVENT_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/DOM/event_target.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/host_object_internal.h"
#include "bindings/jsc/js_context_internal.h"
#include <unordered_map>
#include <vector>

namespace kraken::binding::jsc {

void bindTouchEvent(std::unique_ptr<JSContext> &context);

struct NativeTouchEvent;
struct NativeTouch;
class JSTouch;
class JSTouchList;

class JSTouchEvent : public JSEvent {
public:
  DEFINE_OBJECT_PROPERTY(TouchEvent, 7, touches, targetTouches, changedTouches, altKey, metaKey, ctrlKey, shiftKey)

  static std::unordered_map<JSContext *, JSTouchEvent *> instanceMap;
  OBJECT_INSTANCE(JSTouchEvent)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSTouchEvent() = delete;
  ~JSTouchEvent();
  explicit JSTouchEvent(JSContext *context);
};

class TouchEventInstance : public EventInstance {
public:
  TouchEventInstance() = delete;
  explicit TouchEventInstance(JSTouchEvent *jsTouchEvent, NativeTouchEvent *nativeTouchEvent);
  explicit TouchEventInstance(JSTouchEvent *jsTouchEvent, JSStringRef data);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~TouchEventInstance() override;

  NativeTouchEvent *nativeTouchEvent;

private:
  JSTouchList *m_touches;
  JSTouchList *m_targetTouches;
  JSTouchList *m_changedTouches;
};

class JSTouchList : public HostObject {
public:
  DEFINE_OBJECT_PROPERTY(TouchList, 1, length)

  JSTouchList() = delete;
  explicit JSTouchList(JSContext *context, NativeTouch **touches, int64_t length);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  std::vector<JSTouch *> m_touchList;
};

class JSTouch : public HostObject {
public:
  DEFINE_OBJECT_PROPERTY(Touch, 15, identifier, target, clientX, clientY, screenX, screenY, pageX, pageY, radiusX,
                         radiusY, rotationAngle, force, altitudeAngle, azimuthAngle, touchType)

  JSTouch() = delete;
  explicit JSTouch(JSContext *context, NativeTouch *touch);
  ~JSTouch() override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  NativeTouch *m_nativeTouch;
};

struct NativeTouch {
  int64_t identifier;
  NativeEventTarget *target;
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

struct NativeTouchEvent {
  NativeTouchEvent() = delete;
  explicit NativeTouchEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;

  NativeTouch **touches;
  int64_t touchLength;

  NativeTouch **targetTouches;
  int64_t targetTouchesLength;

  NativeTouch **changedTouches;
  int64_t changedTouchesLength;

  int64_t altKey;
  int64_t metaKey;
  int64_t ctrlKey;
  int64_t shiftKey;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_TOUCH_EVENT_H
