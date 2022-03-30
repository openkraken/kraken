/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_ATOM_STRING_H_
#define KRAKENBRIDGE_BINDINGS_QJS_ATOM_STRING_H_

#include <quickjs/quickjs.h>
#include <memory>
#include "foundation/macros.h"
#include "foundation/native_string.h"
#include "native_string_utils.h"

namespace kraken {

// An AtomicString instance represents a string, and multiple AtomicString
// instances can share their string storage if the strings are
// identical. Comparing two AtomicString instances is much faster than comparing
// two String instances because we just check string storage identity.
class AtomicString {
 public:
  AtomicString() = default;
  AtomicString(JSAtom atom) : atom_(atom) {}

  // Return the undefined string value from atom key.
  virtual JSValue ToQuickJS(JSContext* ctx) const = 0;

  bool operator==(const AtomicString& other) const { return other.atom_ == this->atom_; }

 protected:
  JSAtom atom_{JS_ATOM_NULL};
};

// AtomicString which holding quickjs built-in atoms string.
// These string are stored in JSRuntime instead of JSContext.
// So it can be used by any JSContext and don't needs to be freed.
class PersistentAtomicString : public AtomicString {
 public:
  PersistentAtomicString(JSAtom atom): AtomicString(atom) {};

  JSValue ToQuickJS(JSContext* ctx) const override;
};

// PeriodicAtomicString holding string atom key created by JSContext.
// Could be freed when string refer_count set to 0.
class PeriodicAtomicString : public AtomicString {
  // Should only allocate on stack.
  KRAKEN_DISALLOW_NEW();

 public:
  static PeriodicAtomicString Empty(JSContext* ctx) { return PeriodicAtomicString(ctx); };

  explicit PeriodicAtomicString(JSContext* ctx) : ctx_(ctx), AtomicString(JS_ATOM_NULL) {}
  explicit PeriodicAtomicString(JSContext* ctx, const std::string& string) : ctx_(ctx), AtomicString(JS_NewAtom(ctx, string.c_str())) {}
  explicit PeriodicAtomicString(JSContext* ctx, JSAtom atom) : ctx_(ctx), AtomicString(JS_DupAtom(ctx, atom)) {};
  explicit PeriodicAtomicString(JSContext* ctx, JSValue value) : ctx_(ctx), AtomicString(JS_ValueToAtom(ctx, value)){};
  ~PeriodicAtomicString() { JS_FreeAtom(ctx_, atom_); }

  JSValue ToQuickJS(JSContext* ctx) const { return JS_AtomToValue(ctx, atom_); }

  // Copy assignment
  PeriodicAtomicString(PeriodicAtomicString const& value) {
    if (&value != this) {
      atom_ = JS_DupAtom(ctx_, value.atom_);
    }
    ctx_ = value.ctx_;
  };
  PeriodicAtomicString& operator=(const PeriodicAtomicString& other) {
    if (&other != this) {
      atom_ = JS_DupAtom(ctx_, other.atom_);
    }
    return *this;
  };

  // Move assignment
  PeriodicAtomicString(PeriodicAtomicString&& value) noexcept {
    if (&value != this) {
      atom_ = JS_DupAtom(ctx_, value.atom_);
    }
    ctx_ = value.ctx_;
  };
  PeriodicAtomicString& operator=(PeriodicAtomicString&& value) noexcept {
    if (&value != this) {
      atom_ = JS_DupAtom(ctx_, value.atom_);
    }
    ctx_ = value.ctx_;
    return *this;
  }

 private:
  PeriodicAtomicString() = delete;
  JSContext* ctx_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_ATOM_STRING_H_
