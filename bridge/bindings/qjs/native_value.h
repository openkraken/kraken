/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_NATIVE_VALUE_H
#define KRAKENBRIDGE_NATIVE_VALUE_H

#include "js_context.h"

enum NativeTag {
  TAG_STRING      = 0,
  TAG_INT         = 1,
  TAG_BOOL        = 2,
  TAG_NULL        = 3,
  TAG_FLOAT64     = 4,
  TAG_JSON        = 5,
  TAG_POINTER     = 6
};

enum JSPointerType {
  NativeBoundingClientRect       = 0,
  NativeCanvasRenderingContext2D = 1,
  NativeEventTarget = 2
};

namespace kraken::binding::qjs {

// Exchange data struct between dart and C++
struct NativeValue {
  double float64;
  union {
    int64_t int64;
    void *ptr;
  } u;
  int64_t tag;
};

NativeValue Native_NewNull();
NativeValue Native_NewString(NativeString *string);
NativeValue Native_NewCString(std::string string);
NativeValue Native_NewFloat64(double value);
NativeValue Native_NewBool(bool value);
NativeValue Native_NewInt32(int32_t value);
NativeValue Native_NewPtr(JSPointerType pointerType, void *ptr);
NativeValue Native_NewJSON(JSContext *context, JSValue &value);
NativeValue jsValueToNativeValue(QjsContext *ctx, JSValue &value);
JSValue nativeValueToJSValue(JSContext *context, NativeValue &value);

}

#endif // KRAKENBRIDGE_NATIVE_VALUE_H
