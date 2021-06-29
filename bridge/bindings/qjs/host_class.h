/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_CLASS_H
#define KRAKENBRIDGE_HOST_CLASS_H

#include "js_context.h"

namespace kraken::binding::qjs {

static JSClassID kHostClassClassId = 52;
static JSClassID kHostClassInstanceClassId = 53;

class HostClass {
public:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(HostClass);

  HostClass(JSContext *context, std::string name)
    : m_context(context), m_name(std::move(name)), m_ctx(context->ctx()), m_contextId(context->getContextId()) {
    JSClassDef def{};
    def.class_name = name.c_str();
    def.finalizer = proxyFinalize;
    def.call = proxyCall;
    JS_NewClass(context->runtime(), kHostClassClassId, &def);
    classObject = JS_NewObjectClass(context->ctx(), kHostClassClassId);
    m_prototypeObject = JS_NewObject(m_ctx);

    JSAtom prototypeKey = JS_NewAtom(m_ctx, "prototype");
    JS_DefinePropertyValue(m_ctx, classObject, prototypeKey, m_prototypeObject, JS_PROP_C_W_E);
    JS_FreeAtom(m_ctx, prototypeKey);

    JS_SetConstructorBit(m_ctx, classObject, true);
    JS_SetOpaque(classObject, this);
  };
  virtual ~HostClass() = default;

  virtual JSValue constructor(QjsContext *ctx, JSValue this_val, int argc, JSValueConst *argv) {
    return JS_NewObject(ctx);
  };
  JSValue classObject;

  inline uint32_t contextId() const { return m_contextId; }
  inline JSContext *context() const { return m_context; }
  inline JSValue prototype() const { return m_prototypeObject; };

protected:
  JSValue m_prototypeObject{JS_NULL};
  std::string m_name;
  JSContext *m_context;
  int32_t m_contextId;
  QjsContext *m_ctx;

private:
  static void proxyFinalize(JSRuntime *rt, JSValue val) {
    auto hostObject = static_cast<HostClass *>(JS_GetOpaque(val, kHostClassClassId));
    JS_FreeValue(hostObject->m_ctx, hostObject->classObject);
    JS_FreeValue(hostObject->m_ctx, hostObject->m_prototypeObject);
    delete hostObject;
  };
  static JSValue proxyCall(QjsContext *ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst *argv,
                           int flags) {
    auto *hostClass = static_cast<HostClass *>(JS_GetOpaque(this_val, kHostClassClassId));
    JSValue instance = hostClass->constructor(ctx, this_val, argc, argv);
    JS_SetPrototype(ctx, instance, hostClass->m_prototypeObject);
    return instance;
  }
};

class Instance {
public:
  Instance(HostClass *hostClass, std::string name)
      : m_context(hostClass->context()), m_hostClass(hostClass), m_name(std::move(name)), m_ctx(m_context->ctx()) {
    JSClassDef def{};
    def.class_name = name.c_str();
    def.finalizer = proxyInstanceFinalize;
    JS_NewClass(m_context->runtime(), kHostClassInstanceClassId, &def);
    instanceObject = JS_NewObjectClass(m_ctx, kHostClassInstanceClassId);
    JS_SetOpaque(instanceObject, this);
  };
  JSValue instanceObject;
  virtual ~Instance() = default;

  inline HostClass* prototype() const { return m_hostClass; }
  inline JSContext* context() const { return m_context; }

protected:
  JSContext *m_context{nullptr};
  QjsContext *m_ctx{nullptr};
  HostClass *m_hostClass{nullptr};
  std::string m_name;

  static void proxyInstanceFinalize(JSRuntime *rt, JSValue val) {
    auto *instance = static_cast<Instance *>(JS_GetOpaque(val, kHostClassInstanceClassId));
    JS_FreeValue(instance->m_ctx, instance->instanceObject);
    delete instance;
  };
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_HOST_CLASS_H
