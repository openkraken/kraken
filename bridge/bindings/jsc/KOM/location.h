/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_LOCATION_H
#define KRAKENBRIDGE_LOCATION_H

#include "bindings/jsc/host_object_internal.h"
#include "bindings/jsc/js_context_internal.h"
#include <array>

namespace kraken::binding::jsc {

#define JSLocationName "Location"

class JSWindow;

class JSLocation : public HostObject {
public:
  static JSValueRef reload(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);

  JSLocation(JSContext *context) : HostObject(context, JSLocationName) {}
  ~JSLocation() override;
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;


private:
  JSFunctionHolder m_reload{context, jsObject, this, "reload", reload};
  std::array<JSStringRef, 2> propertyNames {
    JSStringCreateWithUTF8CString("reload"),
    JSStringCreateWithUTF8CString("href")
  };
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_LOCATION_H
