/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_OBJECT_H
#define KRAKENBRIDGE_HOST_OBJECT_H

#include "js_context.h"

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
  virtual void setProperty(std::string &name, JSValueRef value, JSValueRef *exception);

  virtual void getPropertyNames(JSPropertyNameAccumulatorRef accumulator);

private:
  JSClassRef jsClass;
};

template<typename T>
class JSHostObjectHolder {
public:
  JSHostObjectHolder() = delete;
  explicit JSHostObjectHolder(T *hostObject): m_object(hostObject) {
    JSValueProtect(m_object->ctx, m_object->jsObject);
  }
  ~JSHostObjectHolder() {
    JSValueUnprotect(m_object->ctx, m_object->jsObject);
  }
  T* operator*() {
    return m_object;
  }

private:
  T *m_object;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_HOST_OBJECT_H
