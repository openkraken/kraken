/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "custom_element_registry.h"
#include "element.h"

namespace kraken::binding::qjs {

void bindCustomElementRegistry(std::unique_ptr<JSContext> &context) {
  JSValue instance = JS_CallConstructor(context->ctx(), CustomElementRegistry::instance(context.get())->classObject, 0, nullptr);
  context->defineGlobalProperty("customElements", instance);
};

OBJECT_INSTANCE_IMPL(CustomElementRegistry);

std::once_flag kCustomElementRegistryInitFlag;

JSValue CustomElementRegistry::instanceConstructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc,
                                                   JSValue *argv) {
  return (new CustomElementRegistryInstance(this))->instanceObject;
}

CustomElementRegistry::CustomElementRegistry(JSContext *context) : HostClass(context, "CustomElementRegistry") {
  std::call_once(kCustomElementRegistryInitFlag, []() {
    JS_NewClassID(&kCustomElementRegistryClassId);
  });
}

JSClassID CustomElementRegistry::kCustomElementRegistryClassId{0};

static bool checkConstructorName(const char* name) {
  size_t len = strlen(name);
  bool valid = false;

  // Built-in name whitelist.
  if (strcmp(name, "video") == 0) return true;
  if (strcmp(name, "iframe") == 0) return true;

  for (size_t i = 0; i < len; i ++) {
    if (name[i] == '-') valid = true;
  }

  return valid;
}

JSValue CustomElementRegistry::define(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(ctx,
                             "Failed to execute 'define' on 'CustomElementRegistry': 2 arguments required, but only 1 present.");
  }

  JSValue nameValue = argv[0];
  JSValue constructorValue = argv[1];

  if (!JS_IsConstructor(ctx, constructorValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'define' on 'CustomElementRegistry': parameter 2 is not a constructor.");
  }

  const char* name = JS_ToCString(ctx, nameValue);
  if (!checkConstructorName(name)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'define' on 'CustomElementRegistry': \"%s\" is not a valid custom element name", name);
  }

  auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));

//  if (!JS_IsInstanceOf(ctx, constructorValue, Element::instance(context)->classObject)) {
//    return JS_ThrowTypeError(ctx, "Failed to execute 'define' on 'CustomElementRegistry': parameter 2 is not a Element constructor.");
//  }

  auto *constructor = static_cast<Element *>(JS_GetOpaque(constructorValue, Element::classId()));
  Element::defineElement(name, constructor);

  return JS_NULL;
}
JSValue CustomElementRegistry::get(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}
JSValue CustomElementRegistry::whenDefined(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}


}
