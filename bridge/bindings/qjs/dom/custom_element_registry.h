/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CUSTOM_ELEMENT_REGISTRY_H
#define KRAKENBRIDGE_CUSTOM_ELEMENT_REGISTRY_H

#include "bindings/qjs/host_class.h"

namespace kraken::binding::qjs {

void bindCustomElementRegistry(std::unique_ptr<JSContext> &context);

class CustomElementRegistry : public HostClass {
public:
  CustomElementRegistry() = delete;
  explicit CustomElementRegistry(JSContext *context);

  OBJECT_INSTANCE(CustomElementRegistry);

  JSValue instanceConstructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  static JSClassID kCustomElementRegistryClassId;

  static JSValue define(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue get(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue whenDefined(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

private:
  ObjectFunction m_define{m_context, m_prototypeObject, "define", define, 2};
  ObjectFunction m_get{m_context, m_prototypeObject, "get", get, 1};
  ObjectFunction m_whenDefined{m_context, m_prototypeObject, "whenDefined", whenDefined, 1};
};

class CustomElementRegistryInstance : public Instance {
public:
  CustomElementRegistryInstance() = delete;
  explicit CustomElementRegistryInstance(CustomElementRegistry *customElementRegistry)
    : Instance(customElementRegistry,
               "CustomElementRegistry",
               nullptr,
               CustomElementRegistry::kCustomElementRegistryClassId,
               nullptr) {}
private:

};

}

#endif //KRAKENBRIDGE_CUSTOM_ELEMENT_REGISTRY_H
