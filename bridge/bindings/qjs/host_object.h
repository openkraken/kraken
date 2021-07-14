/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_OBJECT_H
#define KRAKENBRIDGE_HOST_OBJECT_H

#include "js_context.h"

namespace kraken::binding::qjs {

static JSClassID kHostObjectClassId = 54;

class HostObject {
public:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(HostObject);

  HostObject() = delete;
  HostObject(JSContext *context, std::string name)
    : m_context(context), m_name(std::move(name)), m_ctx(context->ctx()), m_contextId(context->getContextId()) {
    JSClassDef def{};
    def.class_name = m_name.c_str();
    def.finalizer = proxyFinalize;
    JS_NewClass(context->runtime(), kHostObjectClassId, &def);
    jsObject = JS_NewObjectClass(m_ctx, kHostObjectClassId);
    JS_SetOpaque(jsObject, this);
  }

  JSValue jsObject;

protected:
  virtual ~HostObject() = default;
  std::string m_name;
  JSContext *m_context;
  int32_t m_contextId;
  QjsContext *m_ctx;

private:
  static void proxyFinalize(JSRuntime *rt, JSValue val) {
    auto hostObject = static_cast<HostObject *>(JS_GetOpaque(val, kHostObjectClassId));
    if (hostObject->m_context->isValid()) {
      JS_FreeValue(hostObject->m_ctx, hostObject->jsObject);
    }
    delete hostObject;
  };
};

} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_HOST_OBJECT_H
