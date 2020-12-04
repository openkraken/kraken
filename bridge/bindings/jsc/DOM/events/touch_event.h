/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_TOUCH_EVENT_H
#define KRAKENBRIDGE_TOUCH_EVENT_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/DOM/event_target.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/host_object.h"
#include "bindings/jsc/js_context.h"
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
  enum class TouchEventProperty { kTouches, kTargetTouches, kChangedTouches, kAltKey, kMetaKey, kCtrlKey, kShiftKey };

  static std::vector<JSStringRef> &getTouchEventPropertyNames();
  const static std::unordered_map<std::string, TouchEventProperty> &getTouchEventPropertyMap();

  static std::unordered_map<JSContext *, JSTouchEvent *> &getInstanceMap();
  static JSTouchEvent *instance(JSContext *context);

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
  void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
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
  enum TouchListProperty {
    kLength,
  };

  static std::vector<JSStringRef> &getTouchListPropertyNames();
  const static std::unordered_map<std::string, TouchListProperty> &getTouchListPropertyMap();

  JSTouchList() = delete;
  explicit JSTouchList(JSContext *context, NativeTouch **touches, int64_t length);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
private:
  std::vector<JSTouch*> m_touchList;
};

class JSTouch : public HostObject {
public:
  enum TouchProperty {
    kIdentifier,
    kTarget,
    kClientX,
    kClientY,
    kScreenX,
    kScreenY,
    kPageX,
    kPageY,
    kRadiusX,
    kRadiusY,
    kRotationAngle,
    kForce,
    kAltitudeAngle,
    kAzimuthAngle,
    kTouchType,
  };

  static std::vector<JSStringRef> &getTouchPropertyNames();
  const static std::unordered_map<std::string, TouchProperty> &getTouchPropertyMap();

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
