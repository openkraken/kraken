/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_LOCATION_H
#define KRAKENBRIDGE_LOCATION_H

#include "bindings/qjs/host_object.h"
#include "bindings/qjs/js_context.h"

namespace kraken::binding::qjs {

class Location : public HostObject {
 public:
  Location() = delete;
  explicit Location(JSContext* context) : HostObject(context, "Location") {}

  static JSValue reload(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

 private:
  DEFINE_FUNCTION(reload, 0);
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_LOCATION_H
