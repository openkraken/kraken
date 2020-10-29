/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_LOCATION_H
#define KRAKENBRIDGE_LOCATION_H

#include "bindings/jsc/js_context.h"
#include "bindings/jsc/host_object.h"
#include <array>

namespace kraken::binding::jsc {

#define JSLocationName "Location"

void updateLocation(std::string url);

class JSWindow;

class JSLocation : public HostObject {
public:
  JSLocation(JSContext *context) : HostObject(context, JSLocationName) {}

  ~JSLocation() override;
  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;

//  void instanceGetPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  std::array<JSStringRef, 2> propertyNames {
    JSStringCreateWithUTF8CString("reload"),
    JSStringCreateWithUTF8CString("href")
  };
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_LOCATION_H
