/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_OBJECT_H
#define KRAKENBRIDGE_HOST_OBJECT_H

#include "js_context.h"
#include <unordered_map>

namespace kraken::binding::jsc {

class HostObject {
public:
  static JSValueRef proxyGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                     JSValueRef *exception);
  static bool proxySetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value,
                               JSValueRef *exception);
  static void proxyGetPropertyNames(JSContextRef ctx, JSObjectRef object, JSPropertyNameAccumulatorRef propertyNames);
  static void proxyFinalize(JSObjectRef obj);

  HostObject() = delete;
  HostObject(JSContext *context, std::string name);
  std::string name;

  JSContext *context;
  int32_t contextId;
  JSObjectRef jsObject;
  JSContextRef ctx;
  // The C++ object's dtor will be called when the GC finalizes this
  // object.  (This may be as late as when the JSContext is shut down.)
  // You have no control over which thread it is called on.  This will
  // be called from inside the GC, so it is unsafe to do any VM
  // operations which require a JSContext&.  Derived classes' dtors
  // should also avoid doing anything expensive.  Calling the dtor on
  // a js object is explicitly ok.  If you want to do JS operations,
  // or any nontrivial work, you should add it to a work queue, and
  // manage it externally.
  virtual ~HostObject();

  // When JS wants a property with a given name from the HostObject,
  // it will call this method.  If it throws an exception, the call
  // will throw a JS \c Error object. By default this returns undefined.
  // \return the value for the property.
  virtual JSValueRef getProperty(std::string &name, JSValueRef *exception);

  // When JS wants to set a property with a given name on the HostObject,
  // it will call this method. If it throws an exception, the call will
  // throw a JS \c Error object. By default this throws a type error exception
  // mimicking the behavior of a frozen object in strict mode.
  virtual bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception);

  virtual void getPropertyNames(JSPropertyNameAccumulatorRef accumulator);

private:
  JSClassRef jsClass;
};

template<typename T>
class JSHostObjectHolder {
public:
  JSHostObjectHolder() = delete;
  explicit JSHostObjectHolder(JSContext *context, JSObjectRef root, const char* key, T *hostObject): m_object(hostObject), m_context(context) {
    JSStringHolder keyStringHolder = JSStringHolder(context, key);
    JSObjectSetProperty(context->context(), root, keyStringHolder.getString(), hostObject->jsObject, kJSPropertyAttributeNone, nullptr);
  }
  T* operator*() {
    return m_object;
  }

private:
  T *m_object;
  JSContext *m_context{nullptr};
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_HOST_OBJECT_H
