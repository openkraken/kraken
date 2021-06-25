/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_OBJECT_H
#define KRAKENBRIDGE_HOST_OBJECT_H

#include "js_context.h"

namespace kraken::binding::qjs {

template <class T> class HostObject {
public:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(HostObject);

  HostObject() = delete;
  HostObject(JSContext *context, std::string name)
    : m_context(context), m_name(std::move(name)), m_ctx(context->context()), m_contextId(context->getContextId()) {
    JSClassDef def{};
    def.class_name = name.c_str();
    def.finalizer = proxyFinalize;
    int success = JS_NewClass(context->runtime(), kHostObjectClassId, &def);
    assert_m(success == 0, "Can not allocate new Javascript Class.");

    m_jsObject = JS_NewObjectClass(m_ctx, kHostObjectClassId);
    JS_SetOpaque(m_jsObject, this);
  }

  std::string m_name;
  JSContext *m_context;
  int32_t m_contextId;
  JSValue m_jsObject;
  QjsContext *m_ctx;

protected:
  ~HostObject() = default;

private:
  static void proxyFinalize(JSRuntime *rt, JSValue val) {
    auto hostObject = static_cast<T *>(JS_GetOpaque(val, kHostObjectClassId));
    JS_FreeValue(hostObject->m_ctx, hostObject->m_jsObject);
    delete hostObject;
  };
};

class HostObjectProperty {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(HostObjectProperty);

public:
  HostObjectProperty() = delete;
  explicit HostObjectProperty(JSContext *context, JSValueConst thisObject, const char *property,
                              JSCFunction getterFunction, JSCFunction setterFunction) {
    JSValue ge = JS_NewCFunction(context->context(), getterFunction, "get", 0);
    JSValue se = JS_NewCFunction(context->context(), setterFunction, "set", 1);
    JSAtom key = JS_NewAtom(context->context(), property);
    JS_DefinePropertyGetSet(context->context(), thisObject, key, ge, se,
                            JS_PROP_C_W_E);
    JS_FreeAtom(context->context(), key);
  };
};

class HostObjectFunction {
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(HostObjectFunction);

public:
  HostObjectFunction() = delete;
  explicit HostObjectFunction(JSContext *context, JSValueConst thisObject, const char *functionName,
                              JSCFunction function, int argc) {
    JSValue f = JS_NewCFunction(context->context(), function, functionName, argc);
    JSAtom key = JS_NewAtom(context->context(), functionName);
    JS_DefinePropertyValue(context->context(), thisObject, key, f,
                           JS_PROP_C_W_E);
    JS_FreeAtom(context->context(), key);
  };
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_HOST_OBJECT_H
