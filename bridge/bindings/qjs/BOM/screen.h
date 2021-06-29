/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SCREEN_H
#define KRAKENBRIDGE_SCREEN_H

#include "bindings/qjs/host_object.h"
#include "bindings/qjs/js_context.h"
#include "dart_methods.h"

namespace kraken::binding::qjs {

class JSScreen : public HostObject<JSScreen> {
public:
  explicit JSScreen(JSContext *context) : HostObject(context, "Screen"){};
private:
  class WidthPropertyDescriptor {
  public:
    static JSValue getter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
    static JSValue setter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  };

  class HeightPropertyDescriptor {
  public:
    static JSValue getter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
    static JSValue setter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  };

  ObjectProperty m_width{m_context, jsObject, "width", WidthPropertyDescriptor::getter, WidthPropertyDescriptor::setter};
  ObjectProperty m_height{m_context, jsObject, "height", HeightPropertyDescriptor::getter, HeightPropertyDescriptor::setter};
};

void bindScreen(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::qjs

class screen {};

#endif // KRAKENBRIDGE_SCREEN_H
