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
    JSClassExoticMethods exoticMethods;
    exoticMethods.get_own_property_names = static_cast<T *>(this)->getOwnPropertyNames;
    exoticMethods.get_own_property = static_cast<T *>(this)->getOwnProperty;
    exoticMethods.define_own_property = static_cast<T *>(this)->defineOwnProperty;
    exoticMethods.delete_property = static_cast<T *>(this)->deleteProperty;
    def.exotic = &exoticMethods;
    int success = JS_NewClass(JSContext::runtime(), kHostObjectClassId, &def);
    assert_m(success == 0, "Can not allocate new Javascript Class.");

    m_jsObject = JS_NewObjectClass(m_ctx, kHostObjectClassId);
  }

  std::string m_name;
  JSContext *m_context;
  int32_t m_contextId;
  JSValue m_jsObject;
  QjsContext *m_ctx;

protected:
  int getOwnPropertyNames(QjsContext *ctx, JSPropertyEnum **ptab,
                                uint32_t *plen,
                                JSValueConst obj) { return 0; };
  int getOwnProperty(QjsContext *ctx, JSPropertyDescriptor *desc,
                          JSValueConst obj, JSAtom prop) { return 0; };
  int defineOwnProperty(QjsContext *ctx, JSValueConst this_obj,
                             JSAtom prop, JSValueConst val,
                             JSValueConst getter, JSValueConst setter,
                             int flags) { return 0; };
  int deleteProperty(QjsContext *ctx, JSValueConst obj, JSAtom prop) { return 0;};

private:
  ~HostObject() {
    static_cast<T *>(this)->dispose();
  };
  static void proxyFinalize(JSRuntime *rt, JSValue val) {
    auto hostObject = static_cast<T *>(JS_GetOpaque(val, kHostObjectClassId));
    JS_FreeValue(hostObject->m_ctx, hostObject->m_jsObject);
    delete hostObject;
  };
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_HOST_OBJECT_H
