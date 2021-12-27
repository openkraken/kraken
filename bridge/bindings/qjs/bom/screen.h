/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
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
};

void bindScreen(std::unique_ptr<ExecutionContext>& context);

}  // namespace kraken::binding::qjs

class screen {};

#endif  // KRAKENBRIDGE_SCREEN_H
