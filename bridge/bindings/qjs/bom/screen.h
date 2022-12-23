/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_SCREEN_H
#define KRAKENBRIDGE_SCREEN_H

#include "bindings/qjs/executing_context.h"
#include "bindings/qjs/host_object.h"
#include "dart_methods.h"

namespace kraken::binding::qjs {

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

}  // namespace kraken::binding::qjs

class screen {};

#endif  // KRAKENBRIDGE_SCREEN_H
