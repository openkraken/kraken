/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_ATOM_STRING_H_
#define KRAKENBRIDGE_BINDINGS_QJS_ATOM_STRING_H_

#include <memory>
#include <quickjs/quickjs.h>
#include "foundation/macros.h"
#include "foundation/native_string.h"
#include "native_string_utils.h"

namespace kraken {

// ScriptAtom is a stack allocate only QuickJS JSAtom wrapper.
class AtomString final {
  // ScriptAtom should only allocate at stack.
  KRAKEN_DISALLOW_NEW();

 public:
  explicit AtomString(JSContext* ctx, const char* string) : ctx_(ctx), atom_(JS_NewAtom(ctx, string)) {}
  explicit AtomString(JSContext* ctx, JSAtom atom) : ctx_(ctx), atom_(JS_DupAtom(ctx, atom)){};

  ~AtomString() { JS_FreeAtom(ctx_, atom_); }

  JSValue ToQuickJS() const { return JS_AtomToValue(ctx_, atom_); }

  AtomString& operator=(const AtomString& other) {
    if (&other != this) {
      atom_ = JS_DupAtom(ctx_, other.atom_);
    }
    return *this;
  };

 private:
  AtomString() = delete;
  JSContext* ctx_{nullptr};
  JSAtom atom_{JS_ATOM_NULL};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_ATOM_STRING_H_
