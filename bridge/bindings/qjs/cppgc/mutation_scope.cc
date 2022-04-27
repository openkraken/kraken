/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "mutation_scope.h"
#include "core/executing_context.h"

namespace kraken {

MutationScope::MutationScope(ExecutingContext* context) : context_(context) {
  assert(!context->HasMutationScope());
  context->SetMutationScope(*this);
}

MutationScope::~MutationScope() {
  ApplyRecord();
  context_->ClearMutationScope();
}

void MutationScope::RecordDup(ScriptWrappable* wrappable) {
  if (mutation_records_.count(wrappable) == 0) {
    mutation_records_.insert(std::make_pair(wrappable, 0));
  }
  mutation_records_[wrappable]++;
}

void MutationScope::RecordFree(ScriptWrappable* wrappable) {
  if (mutation_records_.count(wrappable) == 0) {
    mutation_records_.insert(std::make_pair(wrappable, 0));
  }
  mutation_records_[wrappable]--;
}

void MutationScope::ApplyRecord() {
  JSContext* ctx = context_->ctx();
  for (auto& entry : mutation_records_) {
    if (entry.second == 0) {
      continue;
    }
    if (entry.second > 0) {
      for (int i = 0; i < entry.second; i++) {
        JS_DupValue(ctx, entry.first->ToQuickJSUnsafe());
      }
      continue;
    } else {
      for (int i = 0; i < -entry.second; i++) {
        JS_FreeValue(ctx, entry.first->ToQuickJSUnsafe());
      }
      continue;
    }
  }
}

}  // namespace kraken
