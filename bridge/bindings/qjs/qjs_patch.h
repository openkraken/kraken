/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_QJS_PATCH_H
#define KRAKENBRIDGE_QJS_PATCH_H

#include <quickjs/quickjs.h>
#include <quickjs/list.h>

struct JSString {
  JSRefCountHeader header; /* must come first, 32-bit */
  uint32_t len : 31;
  uint8_t is_wide_char : 1; /* 0 = 8 bits, 1 = 16 bits characters */
  /* for JS_ATOM_TYPE_SYMBOL: hash = 0, atom_type = 3,
     for JS_ATOM_TYPE_PRIVATE: hash = 1, atom_type = 3
     XXX: could change encoding to have one more bit in hash */
  uint32_t hash : 30;
  uint8_t atom_type : 2; /* != 0 if atom, JS_ATOM_TYPE_x */
  uint32_t hash_next; /* atom_index for JS_ATOM_TYPE_SYMBOL */
#ifdef DUMP_LEAKS
  struct list_head link; /* string list */
#endif
  union {
    uint8_t str8[0]; /* 8 bit strings will get an extra null terminator */
    uint16_t str16[0];
  } u;
};

#ifdef __cplusplus
extern "C" {
#endif

uint16_t *JS_ToUnicode(JSContext *ctx, JSValueConst value, uint32_t *length);
JSValue JS_NewUnicodeString(JSRuntime *runtime, JSContext *ctx, const uint16_t *code, uint32_t length);
JSClassID JSValueGetClassId(JSValue);

#ifdef __cplusplus
}
#endif

#endif // KRAKENBRIDGE_QJS_PATCH_H
