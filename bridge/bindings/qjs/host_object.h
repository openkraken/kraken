/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_OBJECT_H
#define KRAKENBRIDGE_HOST_OBJECT_H

#include "executing_context.h"

namespace kraken::binding::qjs {

class HostObject {
 public:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(HostObject);

  HostObject() = delete;
  HostObject(ExecutionContext* context, std::string name) : m_context(context), m_name(std::move(name)), m_ctx(context->ctx()), m_contextId(context->getContextId()) {
    JSClassDef def{};
    def.class_name = "HostObject";
    def.finalizer = proxyFinalize;
    JS_NewClass(context->runtime(), ExecutionContext::kHostObjectClassId, &def);
    jsObject = JS_NewObjectClass(m_ctx, ExecutionContext::kHostObjectClassId);
    JS_SetOpaque(jsObject, this);
  }

  JSValue jsObject{JS_NULL};

 protected:
  virtual ~HostObject() = default;
  std::string m_name;
  ExecutionContext* m_context;
  int32_t m_contextId;
  JSContext* m_ctx;

 private:
  static void proxyFinalize(JSRuntime* rt, JSValue val) {
    auto hostObject = static_cast<HostObject*>(JS_GetOpaque(val, ExecutionContext::kHostObjectClassId));
    delete hostObject;
  };
};

class ExoticHostObject {
 public:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(ExoticHostObject);

  ExoticHostObject() = delete;
  ExoticHostObject(ExecutionContext* context, std::string name) : m_context(context), m_name(std::move(name)), m_ctx(context->ctx()), m_contextId(context->getContextId()) {
    JSClassExoticMethods* m_exoticMethods = new JSClassExoticMethods{nullptr, nullptr, nullptr, nullptr, nullptr, proxyGetProperty, proxySetProperty};
    JSClassDef def{};
    def.class_name = m_name.c_str();
    def.finalizer = proxyFinalize;
    def.exotic = m_exoticMethods;
    JS_NewClass(context->runtime(), ExecutionContext::kHostExoticObjectClassId, &def);
    jsObject = JS_NewObjectClass(m_ctx, ExecutionContext::kHostExoticObjectClassId);
    JS_SetOpaque(jsObject, this);
  }

  JSValue jsObject{JS_NULL};

  static JSValue proxyGetProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver) {
    auto* object = static_cast<ExoticHostObject*>(JS_GetOpaque(obj, ExecutionContext::kHostExoticObjectClassId));
    return object->getProperty(ctx, obj, atom, receiver);
  };
  static int proxySetProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags) {
    auto* object = static_cast<ExoticHostObject*>(JS_GetOpaque(obj, ExecutionContext::kHostExoticObjectClassId));
    return object->setProperty(ctx, obj, atom, value, receiver, flags);
  };

  virtual JSValue getProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst receiver);
  virtual int setProperty(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value, JSValueConst receiver, int flags);

 protected:
  virtual ~ExoticHostObject() = default;
  std::string m_name;
  ExecutionContext* m_context;
  int32_t m_contextId;
  JSContext* m_ctx;

  static void proxyFinalize(JSRuntime* rt, JSValue val) {
    auto hostObject = static_cast<ExoticHostObject*>(JS_GetOpaque(val, ExecutionContext::kHostExoticObjectClassId));
    delete hostObject;
  };
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_HOST_OBJECT_H
