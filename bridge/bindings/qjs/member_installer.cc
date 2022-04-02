/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "member_installer.h"
#include <quickjs/quickjs.h>
#include "core/executing_context.h"
#include "qjs_engine_patch.h"

namespace kraken {

int combinePropFlags(JSPropFlag a, JSPropFlag b) {
  return a | b;
}
int combinePropFlags(JSPropFlag a, JSPropFlag b, JSPropFlag c) {
  return a | b | c;
}

// The read object's method or properties via Proxy, we should redirect this_val from Proxy into target property of
// proxy object.
static JSValue handleCallThisOnProxy(JSContext* ctx,
                                     JSValueConst this_val,
                                     int argc,
                                     JSValueConst* argv,
                                     int data_len,
                                     JSValueConst* data) {
  JSValue f = data[0];
  JSValue result;
  if (JS_IsProxy(this_val)) {
    result = JS_Call(ctx, f, JS_GetProxyTarget(this_val), argc, argv);
  } else {
    // If this_val is undefined or null, this_val should set to globalThis.
    if (JS_IsUndefined(this_val) || JS_IsNull(this_val)) {
      this_val = JS_GetGlobalObject(ctx);
      result = JS_Call(ctx, f, this_val, argc, argv);
      JS_FreeValue(ctx, this_val);
    } else {
      result = JS_Call(ctx, f, this_val, argc, argv);
    }
  }
  return result;
}

void MemberInstaller::InstallAttributes(ExecutingContext* context,
                                        JSValue root,
                                        std::initializer_list<MemberInstaller::AttributeConfig> config) {
  JSContext* ctx = context->ctx();
  for (auto& c : config) {
    JSAtom key = JS_NewAtom(ctx, c.name);

    if (c.getter != nullptr || c.setter != nullptr) {
      JSValue getter = JS_NULL;
      JSValue setter = JS_NULL;

      if (c.getter != nullptr) {
        JSValue f = JS_NewCFunction(ctx, c.getter, "get", 0);
        getter = JS_NewCFunctionData(ctx, handleCallThisOnProxy, 0, 0, 1, &f);
        JS_FreeValue(ctx, f);
      }
      if (c.setter != nullptr) {
        JSValue f = JS_NewCFunction(ctx, c.setter, "set", 1);
        setter = JS_NewCFunctionData(ctx, handleCallThisOnProxy, 1, 0, 1, &f);
        JS_FreeValue(ctx, f);
      }
      JS_DefinePropertyGetSet(ctx, root, key, getter, setter, c.flag);
    } else {
      JS_DefinePropertyValue(ctx, root, key, c.value, c.flag);
    }

    JS_FreeAtom(ctx, key);
  }
}

void MemberInstaller::InstallFunctions(ExecutingContext* context,
                                       JSValue root,
                                       std::initializer_list<FunctionConfig> config) {
  JSContext* ctx = context->ctx();
  for (auto& c : config) {
    JSValue function = JS_NewCFunction(ctx, c.function, c.name, c.length);
    JS_DefinePropertyValueStr(ctx, root, c.name, function, c.flag);
  }
}

}  // namespace kraken
