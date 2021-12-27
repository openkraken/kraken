/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_LOCATION_H
#define KRAKENBRIDGE_LOCATION_H

#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/host_object.h"

namespace kraken::binding::qjs {

class Location : public HostObject {
 public:
  Location() = delete;
  explicit Location(ExecutionContext* context) : HostObject(context, "Location") {}

  static JSValue reload(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

 private:
  DEFINE_FUNCTION(reload, 0);
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_LOCATION_H
