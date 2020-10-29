/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "bindings/jsc/js_context.h"
#include "bindings/jsc/macros.h"
#include "node.h"

namespace kraken::binding::jsc {

class JSDocument :  public JSNode {
public:
  JSDocument(JSContext *context);
  static JSValueRef createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  JSValueRef instanceGetProperty(JSStringRef name, JSValueRef *exception);
};

void bindDocument(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_H
