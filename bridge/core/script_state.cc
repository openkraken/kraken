/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_state.h"
#include "built_in_string.h"
#include "event_type_names.h"

namespace kraken {

JSRuntime* runtime_ = nullptr;
std::atomic<int32_t> runningContexts{0};

ScriptState::ScriptState() {
  runningContexts++;
  bool first_loaded = false;
  if (runtime_ == nullptr) {
    runtime_ = JS_NewRuntime();
    first_loaded = true;
  }
  // Avoid stack overflow when running in multiple threads.
  JS_UpdateStackTop(runtime_);
  ctx_ = JS_NewContext(runtime_);

  if (first_loaded) {
    built_in_string::Init(ctx_);
    event_type_names::Init(ctx_);
  }
}

JSRuntime* ScriptState::runtime() {
  return runtime_;
}

ScriptState::~ScriptState() {
  JS_FreeContext(ctx_);

  // Run GC to clean up remaining objects about m_ctx;
  JS_RunGC(runtime_);

#if DUMP_LEAKS
  if (--runningContexts == 0) {
    // Prebuilt strings stored in JSRuntime. Only needs to dispose when runtime disposed.
    built_in_string::Dispose();
    event_type_names::Dispose();

    JS_FreeRuntime(runtime_);
    runtime_ = nullptr;
  }
#endif
  ctx_ = nullptr;
}
}  // namespace kraken
