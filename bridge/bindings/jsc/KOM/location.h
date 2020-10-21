/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_LOCATION_H
#define KRAKENBRIDGE_LOCATION_H

#include "bindings/jsc/js_context.h"

namespace kraken::binding::jsc {

#define JSLocationName "Location"

void updateLocation(std::string url);

class JSWindow;

class JSLocation : public HostObject {
public:
  JSLocation(JSContext *context): HostObject(context, JSLocationName) {}

  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;

private:

//  Value reload(JSContext &context, const Value &thisVal, const Value *args, size_t count);
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_LOCATION_H
