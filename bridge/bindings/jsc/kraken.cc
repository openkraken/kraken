/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken.h"
#include "bindings/jsc/macros.h"
#include "kraken_bridge.h"
#include "bindings/jsc/js_context.h"
#include <unordered_map>

namespace kraken::binding::jsc {

static JSObjectRef buildKrakenObject(JSContext *context) {
  static std::unordered_map<JSContext*, JSObjectRef> krakenInstanceMap;
  if (!krakenInstanceMap.contains(context)) {
    krakenInstanceMap[context] = JSObjectMake(context->context(), nullptr, nullptr);
    KrakenInfo *krakenInfo = getKrakenInfo();
    JSStringRef userAgentStr = JSStringCreateWithUTF8CString(krakenInfo->getUserAgent(krakenInfo));
    JSC_SET_STRING_PROPERTY(context, krakenInstanceMap[context], "userAgent", JSValueMakeString(context->context(), userAgentStr));
  }
  return krakenInstanceMap[context];
}

void bindKraken() {
  const JSStaticValue krakenStaticValue = {
    "__kraken__",
    [](JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef* exception) -> JSValueRef {
      auto context = reinterpret_cast<JSContext*>(JSObjectGetPrivate(JSContextGetGlobalObject(ctx)));
      JSObjectRef kraken = buildKrakenObject(context);
      return kraken;
    },
    [](JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value, JSValueRef* exception) -> bool {
      return false;
    },
    kJSPropertyAttributeReadOnly
  };

  JSContext::globalValue.emplace_back(krakenStaticValue);
}

} // namespace kraken::binding::jsc
