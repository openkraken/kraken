/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_WRAPPER_TYPE_INFO_H
#define KRAKENBRIDGE_WRAPPER_TYPE_INFO_H

#include <quickjs/quickjs.h>
#include <cassert>
#include "bindings/qjs/qjs_engine_patch.h"

namespace kraken {

// Define all built-in wrapper class id.
enum {
  JS_CLASS_GC_TRACKER = JS_CLASS_INIT_COUNT + 1,
  JS_CLASS_BLOB,
  JS_CLASS_EVENT,
  JS_CLASS_ERROR_EVENT,
  JS_CLASS_EVENT_TARGET,
  JS_CLASS_NODE,
  JS_CLASS_ELEMENT,
  JS_CLASS_DOCUMENT,
  JS_CLASS_CHARACTER_DATA,
  JS_CLASS_TEXT,
  JS_CLASS_COMMENT,
  JS_CLASS_NODE_LIST,
  JS_CLASS_DOCUMENT_FRAGMENT,
  JS_CLASS_BOUNDING_CLIENT_RECT,
  JS_CLASS_ELEMENT_ATTRIBUTES,
  JS_CLASS_HTML_ELEMENT,
  JS_CLASS_HTML_DIV_ELEMENT,
  JS_CLASS_HTML_BODY_ELEMENT,
  JS_CLASS_HTML_HEAD_ELEMENT,
  JS_CLASS_HTML_HTML_ELEMENT,
  JS_CLASS_HTML_UNKNOWN_ELEMENT,

  JS_CLASS_CUSTOM_CLASS_INIT_COUNT /* last entry for predefined classes */
};

// Callback when get property using index.
// exp: obj[0]
using IndexedPropertyGetterHandler = JSValue (*)(JSContext* ctx, JSValue obj, uint32_t index);

// Callback when get property using string or symbol.
// exp: obj['hello']
using StringPropertyGetterHandler = JSValue (*)(JSContext* ctx, JSValue obj, JSAtom atom);

// Callback when set property using index.
// exp: obj[0] = value;
using IndexedPropertySetterHandler = bool (*)(JSContext* ctx, JSValueConst obj, uint32_t index, JSValueConst value);

// Callback when set property using string or symbol.
// exp: obj['hello'] = value;
using StringPropertySetterHandler = bool (*)(JSContext* ctx, JSValueConst obj, JSAtom atom, JSValueConst value);

// Callback when check property exist on object.
// exp: 'hello' in obj;
using StringPropertyCheckerHandler = bool (*)(JSContext *ctx, JSValueConst obj, JSAtom atom);

// This struct provides a way to store a bunch of information that is helpful
// when creating quickjs objects. Each quickjs bindings class has exactly one static
// WrapperTypeInfo member, so comparing pointers is a safe way to determine if
// types match.
class WrapperTypeInfo final {
 public:
  bool equals(const WrapperTypeInfo* that) const { return this == that; }

  bool isSubclass(const WrapperTypeInfo* that) const {
    for (const WrapperTypeInfo* current = this; current; current = current->parent_class) {
      if (current == that)
        return true;
    }
    return false;
  }

  JSClassID classId{0};
  const char* className{nullptr};
  const WrapperTypeInfo* parent_class{nullptr};
  JSClassCall* callFunc{nullptr};
  IndexedPropertyGetterHandler indexed_property_getter_handler_{nullptr};
  IndexedPropertySetterHandler indexed_property_setter_handler_{nullptr};
  StringPropertyGetterHandler string_property_getter_handler_{nullptr};
  StringPropertySetterHandler string_property_setter_handler_{nullptr};
  StringPropertyCheckerHandler string_property_checker_handler_{nullptr};
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_WRAPPER_TYPE_INFO_H
