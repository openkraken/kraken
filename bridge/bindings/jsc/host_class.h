/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_CLASS_H
#define KRAKENBRIDGE_HOST_CLASS_H

#include "js_context.h"

namespace kraken::binding::jsc {

class HostClass {
public:
  static void proxyInitialize(JSContextRef ctx, JSObjectRef object);
  static void proxyFinalize(JSObjectRef object);
  static bool proxyHasInstance(JSContextRef ctx, JSObjectRef constructor, JSValueRef possibleInstance,
                               JSValueRef *exception);
  static JSObjectRef proxyCallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                            const JSValueRef arguments[], JSValueRef *exception);
  static void proxyInstanceInitialize(JSContextRef ctx, JSObjectRef object);
  static JSValueRef proxyInstanceGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                             JSValueRef *exception);
  static bool proxyInstanceSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value,
                                       JSValueRef *exception);
  static void proxyInstanceGetPropertyNames(JSContextRef ctx, JSObjectRef object,
                                            JSPropertyNameAccumulatorRef propertyNames);
  static void proxyInstanceFinalize(JSObjectRef obj);

  HostClass() = delete;
  HostClass(JSContext *context, std::string name);
  HostClass(JSContext *context, HostClass *parentHostClass, std::string name, const JSStaticFunction *staticFunction,
            const JSStaticValue *staticValue);
  // Triggered when this HostClass had been finalized by GC.
  virtual ~HostClass();

  virtual JSObjectRef constructInstance(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                        const JSValueRef *arguments, JSValueRef *exception);

  // Triggered when search property on prototype object.
  virtual JSValueRef prototypeGetProperty(JSStringRef name, JSValueRef *exception);
  // Triggered when set property on prototype object.
  virtual void prototypeSetProperty(JSStringRef name, JSValueRef value, JSValueRef *exception);

  // The instance class represent every javascript instance objects created by new expression.
  class Instance {
  public:
    Instance() = delete;
    explicit Instance(HostClass *hostClass);
    virtual ~Instance();
    virtual void initialized();
    virtual JSValueRef getProperty(JSStringRef name, JSValueRef *exception);
    virtual void setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception);
    virtual void getPropertyNames(JSPropertyNameAccumulatorRef accumulator);

    JSObjectRef object{nullptr};
    HostClass *hostClass{nullptr};
  };

  std::string _name;
  JSContext *context{nullptr};
  JSContextRef ctx{nullptr};
  // The javascript constructor function.
  JSObjectRef classObject{nullptr};
  // The class template of javascript instance objects.
  JSClassRef instanceClass{nullptr};

private:
  // The class template of javascript constructor function.
  JSClassRef jsClass{nullptr};
  HostClass *_parentHostClass{nullptr};
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_HOST_CLASS_H
