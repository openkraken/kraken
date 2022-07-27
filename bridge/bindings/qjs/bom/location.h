/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_LOCATION_H
#define BRIDGE_LOCATION_H

#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/host_object.h"

namespace webf::binding::qjs {

class Location : public HostObject {
 public:
  Location() = delete;
  explicit Location(ExecutionContext* context) : HostObject(context, "Location") {}

  static JSValue reload(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

 private:
  DEFINE_FUNCTION(reload, 0);
};

}  // namespace webf::binding::qjs

#endif  // BRIDGE_LOCATION_H
