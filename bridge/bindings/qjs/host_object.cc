/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "host_object.h"

namespace kraken::binding::qjs {

JSValue ExoticHostObject::getProperty(QjsContext *ctx, JSValue obj, JSAtom atom, JSValue receiver) {
  return JS_NULL;
}
int ExoticHostObject::setProperty(QjsContext *ctx, JSValue obj, JSAtom atom, JSValue value, JSValue receiver,
                                  int flags) {
  return 0;
}

}
