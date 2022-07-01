/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MUTATION_SCOPE_H_
#define KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MUTATION_SCOPE_H_

#include <quickjs/quickjs.h>
#include <unordered_map>
#include "foundation/macros.h"

namespace kraken {

class ExecutingContext;
class ScriptWrappable;

/**
 * A stack-allocated class that record all members mutations in stack scope.
 */
class MemberMutationScope {
  KRAKEN_DISALLOW_NEW();

 public:
  MemberMutationScope() = delete;
  explicit MemberMutationScope(ExecutingContext* context);
  ~MemberMutationScope();

  void SetParent(MemberMutationScope* parent_scope);
  [[nodiscard]] MemberMutationScope* Parent() const;

  void RecordFree(ScriptWrappable* wrappable);

 private:
  void ApplyRecord();

  MemberMutationScope* parent_scope_{nullptr};
  ExecutingContext* context_;
  std::unordered_map<ScriptWrappable*, int> mutation_records_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MUTATION_SCOPE_H_
