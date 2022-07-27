/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "host_object.h"

namespace webf::binding::qjs {

JSValue ExoticHostObject::getProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  return JS_NULL;
}
int ExoticHostObject::setProperty(JSContext* ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver, int flags) {
  return 0;
}

}  // namespace webf::binding::qjs
