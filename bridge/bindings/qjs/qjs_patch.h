/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_QJS_PATCH_H
#define KRAKENBRIDGE_QJS_PATCH_H

#include <quickjs/quickjs.h>

#ifdef __cplusplus
extern "C" {
#endif

uint16_t *JS_ToUnicode(JSContext *ctx, JSValueConst value, uint32_t *length);

#ifdef __cplusplus
}
#endif

#endif // KRAKENBRIDGE_QJS_PATCH_H
