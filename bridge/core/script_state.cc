/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_state.h"

namespace kraken {

JSRuntime* runtime_ = nullptr;
std::atomic<int32_t> runningContexts{0};

ScriptState::ScriptState() {
  runningContexts++;
  if (runtime_ == nullptr) {
    runtime_ = JS_NewRuntime();
  }
  // Avoid stack overflow when running in multiple threads.
  JS_UpdateStackTop(runtime_);
  ctx_ = JS_NewContext(runtime_);
}

JSRuntime * ScriptState::runtime() {
  return runtime_;
}

ScriptState::~ScriptState() {
  JS_FreeContext(ctx_);

  // Run GC to clean up remaining objects about m_ctx;
  JS_RunGC(runtime_);

#if DUMP_LEAKS
  if (--runningContexts == 0) {
    JS_FreeRuntime(runtime_);
    runtime_ = nullptr;
  }
#endif
  ctx_ = nullptr;
}
}
