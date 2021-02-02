/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_CLASS_H
#define KRAKENBRIDGE_HOST_CLASS_H

#include "js_context_internal.h"
#include <unordered_map>

namespace kraken::binding::jsc {

class HostClass {
public:
  static void proxyFinalize(JSObjectRef object);
  static bool proxyHasInstance(JSContextRef ctx, JSObjectRef constructor, JSValueRef possibleInstance,
                               JSValueRef *exception);
  static JSValueRef proxyCallAsFunction(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
  static JSObjectRef proxyCallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                            const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef proxyGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                     JSValueRef *exception);
  static JSValueRef proxyInstanceGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                             JSValueRef *exception);
  static JSValueRef proxyPrototypeGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef *exception);
  static bool proxyInstanceSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value,
                                       JSValueRef *exception);
  static void proxyInstanceGetPropertyNames(JSContextRef ctx, JSObjectRef object,
                                            JSPropertyNameAccumulatorRef propertyNames);
  static void proxyInstanceFinalize(JSObjectRef obj);

  HostClass() = delete;
  HostClass(JSContext *context, std::string name);
  HostClass(JSContext *context, HostClass *parentHostClass, std::string name, const JSStaticFunction *staticFunction,
            const JSStaticValue *staticValue);

  virtual JSValueRef getProperty(std::string &name, JSValueRef *exception);
  virtual JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception);

  // Triggered when this HostClass had been finalized by GC.
  virtual ~HostClass();

  virtual JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                          const JSValueRef *arguments, JSValueRef *exception);

  // The instance class represent every javascript instance objects created by new expression.
  class Instance {
  public:
    Instance() = delete;
    explicit Instance(HostClass *hostClass);
    virtual ~Instance();
    virtual JSValueRef getProperty(std::string &name, JSValueRef *exception);
    virtual void setProperty(std::string &name, JSValueRef value, JSValueRef *exception);
    virtual void getPropertyNames(JSPropertyNameAccumulatorRef accumulator);

    template<typename T>
    T* prototype() { return reinterpret_cast<T*>(_hostClass); }

    JSObjectRef object{nullptr};
    HostClass *_hostClass{nullptr};
    JSContext *context{nullptr};
    JSContextRef ctx{nullptr};
    int32_t contextId;
  private:
    std::unordered_map<std::string, JSValueRef> m_propertyMap;
  };

  static bool hasProto(JSContextRef ctx, JSObjectRef child, JSValueRef *exception);
  static JSObjectRef getProto(JSContextRef ctx, JSObjectRef child, JSValueRef *exception);
  static void setProto(JSContextRef ctx, JSObjectRef prototype, JSObjectRef child, JSValueRef *exception);

  std::string _name{""};
  JSContext *context{nullptr};
  int32_t contextId;
  JSContextRef ctx{nullptr};
  // The javascript constructor function.
  JSObjectRef classObject{nullptr};
  // The class template of javascript instance objects.
  JSClassRef instanceClass{nullptr};
  // The prototype object of this class.
  JSObjectRef prototypeObject{nullptr};
  JSObjectRef _call{nullptr};

private:

  void initPrototype() const;

  // The class template of javascript constructor function.
  JSClassRef jsClass{nullptr};
  HostClass *_parentHostClass{nullptr};
};

template <typename T> class JSHostClassHolder {
public:
  JSHostClassHolder() = delete;
  explicit JSHostClassHolder(T *hostClass) : m_object(hostClass) {
    JSValueProtect(m_object->ctx, m_object->object);
  }
  ~JSHostClassHolder() {
    JSValueUnprotect(m_object->ctx, m_object->object);
  }
  T *operator*() {
    return m_object;
  }

private:
  T *m_object;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_HOST_CLASS_H
