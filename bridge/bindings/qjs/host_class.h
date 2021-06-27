/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_CLASS_H
#define KRAKENBRIDGE_HOST_CLASS_H

#include "js_context.h"

namespace kraken::binding::qjs {

template <class T> class HostClass {
public:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(HostClass);

  HostClass(JSContext *context, std::string name): m_context(context), m_name(std::move(name)), m_ctx(context->context()), m_contextId(context->getContextId()) {
    JSClassDef def{};
    def.class_name = name.c_str();
    def.finalizer = proxyFinalize;
    def.call = proxyCall;
    int success = JS_NewClass(context->runtime(), kHostClassClassId, &def);
    assert_m(success == 0, "Can not allocate new Javascript Class.");
    m_classObject = JS_NewObjectClass(context->context(), kHostClassClassId);
    m_prototypeObject = JS_NewObject(m_ctx);

    JSAtom prototypeKey = JS_NewAtom(m_ctx, "prototype");
    JS_DefinePropertyValue(m_ctx, m_classObject, prototypeKey, m_prototypeObject, JS_PROP_C_W_E);
    JS_FreeAtom(m_ctx, prototypeKey);

    JS_SetConstructorBit(m_ctx, m_classObject, true);
    JS_SetOpaque(m_classObject, this);
  };

  JSValue m_classObject;
  JSValue m_prototypeObject;
  std::string m_name;
  JSContext *m_context;
  int32_t m_contextId;
  QjsContext *m_ctx;

private:
  static void proxyFinalize(JSRuntime *rt, JSValue val) {
    auto hostObject = static_cast<T *>(JS_GetOpaque(val, kHostObjectClassId));
    JS_FreeValue(hostObject->m_ctx, hostObject->m_classObject);
    delete hostObject;
  };
  static JSValue proxyCall(QjsContext *ctx, JSValueConst func_obj,
                        JSValueConst this_val, int argc, JSValueConst *argv,
                        int flags) {
    auto *hostClass = static_cast<HostClass *>(JS_GetOpaque(this_val, kHostClassClassId));
    JSValue obj = JS_NewObject(ctx);
    JS_SetPrototype(ctx, obj, hostClass->m_prototypeObject);
    return obj;
  }
};

class HostClassFunction {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(HostClassFunction);

public:
  HostClassFunction() = delete;
  explicit HostClassFunction(JSContext *context, JSValueConst thisObject, const char *functionName,
                              JSCFunction function, int argc) {
    JSValue f = JS_NewCFunction(context->context(), function, functionName, argc);
    JSAtom key = JS_NewAtom(context->context(), functionName);
    JS_DefinePropertyValue(context->context(), thisObject, key, f,
                           JS_PROP_C_W_E);
    JS_FreeAtom(context->context(), key);
  };
};

}


#endif // KRAKENBRIDGE_HOST_CLASS_H
