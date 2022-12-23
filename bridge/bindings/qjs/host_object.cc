/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "host_object.h"

namespace kraken::binding::qjs {

JSValue ExoticHostObject::getProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  return JS_NULL;
}
int ExoticHostObject::setProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  return 0;
}

}  // namespace kraken::binding::qjs
