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
//
// AtomicString instances are not thread-safe. An AtomicString instance created
// in a thread must be used only in the creator thread.
class AtomString final {
  // ScriptAtom should only allocate at stack.
  KRAKEN_DISALLOW_NEW();

 public:
  static AtomString Empty(JSContext* ctx) { return AtomString(ctx, JS_ATOM_NULL); };

  explicit AtomString(JSContext* ctx, const std::string& string) : ctx_(ctx), atom_(JS_NewAtom(ctx, string.c_str())) {}
  explicit AtomString(JSContext* ctx, JSAtom atom) : ctx_(ctx), atom_(JS_DupAtom(ctx, atom)){};
  explicit AtomString(JSContext* ctx, JSValue value) : ctx_(ctx), atom_(JS_ValueToAtom(ctx, value)){};

  ~AtomString() { JS_FreeAtom(ctx_, atom_); }

  JSValue ToQuickJS() const { return JS_AtomToValue(ctx_, atom_); }

  // Copy assignment
  AtomString(AtomString const& value) {
    if (&value != this) {
      atom_ = JS_DupAtom(ctx_, value.atom_);
    }
    ctx_ = value.ctx_;
  };
  AtomString& operator=(const AtomString& other) {
    if (&other != this) {
      atom_ = JS_DupAtom(ctx_, other.atom_);
    }
    return *this;
  };

  // Move assignment
  AtomString(AtomString&& value) noexcept {
    if (&value != this) {
      atom_ = JS_DupAtom(ctx_, value.atom_);
    }
    ctx_ = value.ctx_;
  };
  AtomString& operator=(AtomString&& value) noexcept {
    if (&value != this) {
      atom_ = JS_DupAtom(ctx_, value.atom_);
    }
    ctx_ = value.ctx_;
    return *this;
  }

  bool operator==(const AtomString& other) const { return other.atom_ == this->atom_; }

 private:
  AtomString() = delete;
  JSContext* ctx_{nullptr};
  JSAtom atom_{JS_ATOM_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_ATOM_STRING_H_
