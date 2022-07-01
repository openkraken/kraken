/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CONTEXT_DATA_H
#define KRAKENBRIDGE_CONTEXT_DATA_H

#include <quickjs/quickjs.h>
#include <unordered_map>
#include "bindings/qjs/wrapper_type_info.h"

namespace kraken {

class ExecutingContext;

// Used to hold data that is associated with a single ExecutionContext object, and
// has a 1:1 relationship with ExecutionContext.
class ExecutionContextData final {
 public:
  explicit ExecutionContextData(ExecutingContext* context) : m_context(context){};
  ExecutionContextData(const ExecutionContextData&) = delete;
  ExecutionContextData& operator=(const ExecutionContextData&) = delete;

  // Returns the constructor object that is appropriately initialized.
  JSValue constructorForType(const WrapperTypeInfo* type);
  // Returns the prototype object that is appropriately initialized.
  JSValue prototypeForType(const WrapperTypeInfo* type);

  void Dispose();

 private:
  JSValue constructorForIdSlowCase(const WrapperTypeInfo* type);
  std::unordered_map<const WrapperTypeInfo*, JSValue> constructor_map_;
  std::unordered_map<const WrapperTypeInfo*, JSValue> prototype_map_;

  ExecutingContext* m_context;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_CONTEXT_DATA_H
