/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_SCRIPT_WRAPPABLE_H
#define KRAKENBRIDGE_SCRIPT_WRAPPABLE_H

#include <quickjs/quickjs.h>
#include "garbage_collected.h"
#include "wrapper_type_info.h"

namespace kraken {

class ScriptValue;

// Defines |GetWrapperTypeInfo| virtual method which returns the WrapperTypeInfo
// of the instance. Also declares a static member of type WrapperTypeInfo, of
// which the definition is given by the IDL code generator.
//
// All the derived classes of ScriptWrappable, regardless of directly or
// indirectly, must write this macro in the class definition as long as the
// class has a corresponding .idl file.
#define DEFINE_WRAPPERTYPEINFO()                                                             \
 public:                                                                                     \
  const WrapperTypeInfo* GetWrapperTypeInfo() const override { return &wrapper_type_info_; } \
  static const WrapperTypeInfo* GetStaticWrapperTypeInfo() { return &wrapper_type_info_; }   \
                                                                                             \
 private:                                                                                    \
  static const WrapperTypeInfo& wrapper_type_info_

// ScriptWrappable provides a way to map from/to C++ DOM implementation to/from
// JavaScript object (platform object).  ToQuickJS() converts a ScriptWrappable to
// a QuickJS object and toScriptWrappable() converts a QuickJS object back to
// a ScriptWrappable.
class ScriptWrappable : public GarbageCollected<ScriptWrappable> {
 public:
  ScriptWrappable() = delete;

  explicit ScriptWrappable(JSContext* ctx);
  virtual ~ScriptWrappable() = default;

  // Returns the WrapperTypeInfo of the instance.
  virtual const WrapperTypeInfo* GetWrapperTypeInfo() const = 0;

  void Trace(GCVisitor* visitor) const override{};

  JSValue ToQuickJS();
  ScriptValue ToValue();
  FORCE_INLINE ExecutingContext* GetExecutingContext() const {
    return static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx_));
  };
  FORCE_INLINE JSContext* ctx() const { return ctx_; }
  FORCE_INLINE JSRuntime* runtime() const { return runtime_; }

  void InitializeQuickJSObject() override;

 private:
  JSValue jsObject_{JS_NULL};
  bool wrapped_{false};
  JSContext* ctx_{nullptr};
  JSRuntime* runtime_{nullptr};
  friend class GCVisitor;
};

// Converts a QuickJS object back to a ScriptWrappable.
template <typename ScriptWrappable>
inline ScriptWrappable* toScriptWrappable(JSValue object) {
  return static_cast<ScriptWrappable*>(JS_GetOpaque(object, JSValueGetClassId(object)));
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_SCRIPT_WRAPPABLE_H
