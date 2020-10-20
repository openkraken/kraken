/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

class JSDocument : public HostObject {
public:
  JSDocument(std::unique_ptr<JSContext> &context, std::map<std::string, JSObjectCallAsFunctionCallback> &properties)
    : HostObject(context, properties) {}

  JSValueRef get(std::unique_ptr<JSContext> &context, JSStringRef name, JSValueRef *exception) override {
    return nullptr;
  }

  void set(std::unique_ptr<JSContext> &context, JSStringRef name, JSValueRef value, JSValueRef *exception) override {

  }
};

void bindDocument(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_H
