/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "custom_element_registry.h"
#include "element.h"

namespace kraken::binding::qjs {

void bindCustomElementRegistry(std::unique_ptr<JSContext> &context) {
  JSValue constructor = CustomElementRegistry::instance(context.get())->classObject;
  context->defineGlobalProperty("CustomElementRegistry", constructor);
  JSValue instance = JS_CallConstructor(context->ctx(), constructor, 0, nullptr);
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

static bool checkConstructorName(std::string name) {
  bool valid = false;

  // Built-in name whitelist.
  if (name == "video") return true;
  if (name == "iframe") return true;

  for (size_t i = 0; i < name.length(); i ++) {
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

  const char* cname = JS_ToCString(ctx, nameValue);
  std::string name = std::string(cname);
  JS_FreeCString(ctx, cname);

  if (!checkConstructorName(name)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'define' on 'CustomElementRegistry': \"%s\" is not a valid custom element name", name.c_str());
  }

  auto *context = static_cast<JSContext *>(JS_GetContextOpaque(ctx));
  if (!isJavaScriptExtensionElementConstructor(context, constructorValue)) {
    return JS_ThrowTypeError(ctx, "Failed to execute 'define' on 'CustomElementRegistry': parameter 2 is not a Element constructor.");
  }

  Element::defineElement(name, ctx, constructorValue);

  return JS_NULL;
}
JSValue CustomElementRegistry::get(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}
JSValue CustomElementRegistry::whenDefined(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JSValue();
}


}
