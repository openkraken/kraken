/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_GESTURE_EVENT_H
#define KRAKENBRIDGE_GESTURE_EVENT_H

#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context_internal.h"
#include "bindings/jsc/DOM/event.h"
#include <vector>

namespace kraken::binding::jsc {

  void bindGestureEvent(std::unique_ptr<JSContext> &context);

  class GestureEventInstance;

  struct NativeGestureEvent {
    NativeGestureEvent() = delete;
    explicit NativeGestureEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

    NativeEvent *nativeEvent;

    NativeString *state;

    NativeString *direction;

    double_t deltaX;

    double_t deltaY;

    double_t velocityX;

    double_t velocityY;

    double_t scale;

    double_t rotation;
  };

  class JSGestureEvent : public JSEvent {
  public:
    DEFINE_OBJECT_PROPERTY(GestureEvent, 9, state, direction, deltaX, deltaY, velocityX, velocityY, scale, rotation, initGestureEvent)

    static std::unordered_map<JSContext *, JSGestureEvent *> instanceMap;
    OBJECT_INSTANCE(JSGestureEvent)

    JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                    const JSValueRef *arguments, JSValueRef *exception) override;

    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

  protected:
    JSGestureEvent() = delete;
    explicit JSGestureEvent(JSContext *context);
    ~JSGestureEvent() override;

  private:
    friend GestureEventInstance;
  };

  class GestureEventInstance : public EventInstance {
  public:
    static JSValueRef initGestureEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                      const JSValueRef arguments[], JSValueRef *exception);
    GestureEventInstance() = delete;
    explicit GestureEventInstance(JSGestureEvent *jsGestureEvent, std::string GestureEventType, JSValueRef eventInit, JSValueRef *exception);
    explicit GestureEventInstance(JSGestureEvent *jsGestureEvent, NativeGestureEvent* nativeGestureEvent);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    ~GestureEventInstance() override;

  private:
    friend JSGestureEvent;
    JSValueHolder m_state{context, nullptr};
    JSValueHolder m_direction{context, nullptr};
    JSValueHolder m_deltaX{context, nullptr};
    JSValueHolder m_deltaY{context, nullptr};
    JSValueHolder m_velocityX{context, nullptr};
    JSValueHolder m_velocityY{context, nullptr};
    JSValueHolder m_scale{context, nullptr};
    JSValueHolder m_rotation{context, nullptr};
    JSFunctionHolder m_initGestureEvent{context, this, "initGestureEvent", initGestureEvent};
    NativeGestureEvent* nativeGestureEvent;
  };

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_GESTURE_EVENT_H
