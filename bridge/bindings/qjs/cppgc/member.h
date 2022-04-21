/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MEMBER_H_
#define KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MEMBER_H_

#include <type_traits>
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/script_wrappable.h"
#include "foundation/casting.h"

namespace kraken {

class ScriptWrappable;

template <typename T, typename = std::is_base_of<ScriptWrappable, T>>
class Member {
 public:
  Member() = default;
  Member(T* ptr): raw_(ptr) {}

  T* Get() const { return raw_; }
  void Clear() {
    if (raw_ == nullptr) return;
    auto* wrappable = To<ScriptWrappable>(raw_);
    JS_FreeValue(wrappable->ctx(), wrappable->ToValue().QJSValue());
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
      JS_DupValue(wrappable->ctx(), wrappable->ToValue().QJSValue());
    }
    raw_ = p;
  }

  T* raw_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_CPPGC_MEMBER_H_
