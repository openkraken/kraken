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
  JSDocument(JSContext *context);

  static JSValueRef createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;
  void setProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) override;
};

class DemoClass : public HostClass {
public:
  DemoClass() = delete;
  explicit DemoClass(JSContext *context) : HostClass(context, "Demo"){};
  void constructor(JSContextRef ctx, JSObjectRef constructor, JSObjectRef newInstance, size_t argumentCount,
                   const JSValueRef *arguments, JSValueRef *exception) override;
  void instanceFinalized(JSObjectRef object) override;
  JSValueRef instanceGetProperty(JSStringRef name, JSValueRef *exception) override;
  void instanceGetPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  void instanceSetProperty(JSStringRef name, JSValueRef value, JSValueRef *exception) override;
};

void bindDocument(std::unique_ptr<JSContext> &context);
void bindDemo(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_H
