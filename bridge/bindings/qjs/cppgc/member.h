/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MEMBER_H_
#define KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MEMBER_H_

#include <type_traits>
#include "bindings/qjs/qjs_engine_patch.h"
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/script_wrappable.h"
#include "foundation/casting.h"
#include "mutation_scope.h"

namespace kraken {

class ScriptWrappable;

/**
 * Members are used in classes to contain strong pointers to other garbage
 * collected objects. All Member fields of a class must be traced in the class'
 * trace method.
 */
template <typename T, typename = std::is_base_of<ScriptWrappable, T>>
class Member {
 public:
  Member() = default;
  Member(T* ptr) {
    SetRaw(ptr);
  }
  ~Member() {
    if (raw_ != nullptr) {
      assert(runtime_ != nullptr);
      // There are two ways to free the member values:
      //  One is by GC marking and sweep stage.
      //  Two is by free directly when running out of function body.
      // We detect the GC phase to handle case two, and free our members by hand(call JS_FreeValueRT directly).
      JSGCPhaseEnum phase = JS_GetEnginePhase(runtime_);
      if (phase == JS_GC_PHASE_DECREF) {
        JS_FreeValueRT(runtime_, raw_->ToQuickJSUnsafe());
      }
    }
  };

  T* Get() const { return raw_; }
  void Clear() {
    if (raw_ == nullptr)
      return;
    auto* wrappable = To<ScriptWrappable>(raw_);
    // Record the free operation to avoid JSObject had been freed immediately.
    if (LIKELY(wrappable->GetExecutingContext()->HasMutationScope())) {
      wrappable->GetExecutingContext()->mutationScope()->RecordFree(wrappable);
    } else {
      JS_FreeValue(wrappable->ctx(), wrappable->ToQuickJSUnsafe());
    }
    raw_ = nullptr;
  }

  // Copy assignment.
  Member& operator=(const Member& other) {
    operator=(other.Get());
    other.Clear();
    return *this;
  }
  // Move assignment.
  Member& operator=(Member&& other) noexcept {
    operator=(other.Get());
    other.Clear();
    return *this;
  }

  Member& operator=(T* other) {
    Clear();
    SetRaw(other);
    return *this;
  }
  Member& operator=(std::nullptr_t) {
    Clear();
    return *this;
  }

  explicit operator bool() const { return Get(); }
  operator T*() const { return Get(); }
  T* operator->() const { return Get(); }
  T& operator*() const { return *Get(); }

 private:
  void SetRaw(T* p) {
    if (p != nullptr) {
      auto* wrappable = To<ScriptWrappable>(p);
      runtime_ = wrappable->runtime();
      JS_DupValue(wrappable->ctx(), wrappable->ToQuickJSUnsafe());
    }
    raw_ = p;
  }

  T* raw_{nullptr};
  JSRuntime* runtime_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MEMBER_H_
