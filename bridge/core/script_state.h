/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CORE_SCRIPT_STATE_H_
#define KRAKENBRIDGE_CORE_SCRIPT_STATE_H_

#include <quickjs/quickjs.h>
#include "bindings/qjs/script_wrappable.h"

namespace kraken {

// ScriptState is an abstraction class that holds all information about script
// execution (e.g., JSContext etc). If you need any info about the script execution, you're expected to
// pass around ScriptState in the code base. ScriptState is in a 1:1
// relationship with JSContext.
class ScriptState {
 public:
  ScriptState();
  ~ScriptState();

  inline JSContext* ctx() { return ctx_; }
  static JSRuntime* runtime();

 private:
  JSContext* ctx_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CORE_SCRIPT_STATE_H_
