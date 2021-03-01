/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_INTERSECTION_CHANGE_EVENT_H
#define KRAKENBRIDGE_INTERSECTION_CHANGE_EVENT_H

#include "bindings/jsc/DOM/event.h"
#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context_internal.h"
#include <unordered_map>
#include <vector>

namespace kraken::binding::jsc {

void bindIntersectionChangeEvent(std::unique_ptr<JSContext> &context);

struct NativeIntersectionChangeEvent;

class JSIntersectionChangeEvent : public JSEvent {
public:
  DEFINE_OBJECT_PROPERTY(IntersectionChange, 1, intersectionRatio)

  static std::unordered_map<JSContext *, JSIntersectionChangeEvent *> instanceMap;
  OBJECT_INSTANCE(JSIntersectionChangeEvent)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSIntersectionChangeEvent() = delete;
  ~JSIntersectionChangeEvent();
  explicit JSIntersectionChangeEvent(JSContext *context);
};

class IntersectionChangeEventInstance : public EventInstance {
public:
  IntersectionChangeEventInstance() = delete;
  explicit IntersectionChangeEventInstance(JSIntersectionChangeEvent *jsIntersectionChangeEvent, NativeIntersectionChangeEvent *nativeIntersectionChangeEvent);
  explicit IntersectionChangeEventInstance(JSIntersectionChangeEvent *jsIntersectionChangeEvent, JSStringRef data);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~IntersectionChangeEventInstance() override;

  NativeIntersectionChangeEvent *nativeIntersectionChangeEvent;

private:
  double intersectionRatio;
};

struct NativeIntersectionChangeEvent {
  NativeIntersectionChangeEvent() = delete;
  explicit NativeIntersectionChangeEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;
  double intersectionRatio;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_INTERSECTION_CHANGE_EVENT_H
