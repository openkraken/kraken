/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_state.h"
#include "binding_call_methods.h"
#include "built_in_string.h"
#include "event_type_names.h"
#include "html_element_factory.h"
#include "html_names.h"

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
    html_names::Init(ctx_);
    binding_call_methods::Init(ctx_);
    // Bump up the built-in classId. To make sure the created classId are larger than JS_CLASS_CUSTOM_CLASS_INIT_COUNT.
    for (int i = 0; i < JS_CLASS_CUSTOM_CLASS_INIT_COUNT - JS_CLASS_GC_TRACKER + 2; i++) {
      JSClassID id{0};
      JS_NewClassID(&id);
    }
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
    html_names::Dispose();
    binding_call_methods::Dispose();
    HTMLElementFactory::Dispose();

    JS_FreeRuntime(runtime_);
    runtime_ = nullptr;
  }
#endif
  ctx_ = nullptr;
}
}  // namespace kraken
