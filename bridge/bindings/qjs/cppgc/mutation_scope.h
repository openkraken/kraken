/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MUTATION_SCOPE_H_
#define KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MUTATION_SCOPE_H_

#include "foundation/macros.h"
#include <quickjs/quickjs.h>
#include <unordered_map>

namespace kraken {

class ExecutingContext;
class ScriptWrappable;

/**
 * A stack-allocated class that record all members mutations in stack scope.
 */
class MutationScope {
  KRAKEN_DISALLOW_NEW();
 public:
  MutationScope() = delete;
  explicit MutationScope(ExecutingContext* context);
  ~MutationScope();

  void RecordDup(ScriptWrappable* wrappable);
  void RecordFree(ScriptWrappable* wrappable);

 private:

  void ApplyRecord();

  ExecutingContext* context_;
  std::unordered_map<ScriptWrappable*, int> mutation_records_;
};


}

#endif  // KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MUTATION_SCOPE_H_
