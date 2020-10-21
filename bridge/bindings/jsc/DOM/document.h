/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "bindings/jsc/js_context.h"
#include "bindings/jsc/macros.h"

namespace kraken::binding::jsc {

class JSDocument : public HostObject {
public:
  JSDocument(std::unique_ptr<JSContext> &context);

  static JSValueRef createElement(JSContextRef ctx, JSObjectRef function,
                                  JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
  void setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) override;
};

void bindDocument(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_H
