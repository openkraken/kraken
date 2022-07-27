/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_SCREEN_H
#define BRIDGE_SCREEN_H

#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/host_object.h"
#include "dart_methods.h"

namespace webf::binding::qjs {

class Screen : public HostObject {
 public:
  explicit Screen(ExecutionContext* context) : HostObject(context, "Screen"){};

 private:
  DEFINE_READONLY_PROPERTY(width);
  DEFINE_READONLY_PROPERTY(height);
  DEFINE_READONLY_PROPERTY(availWidth);
  DEFINE_READONLY_PROPERTY(availHeight);
};

void bindScreen(ExecutionContext* context);

}  // namespace webf::binding::qjs

class screen {};

#endif  // BRIDGE_SCREEN_H
