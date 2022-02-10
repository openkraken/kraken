/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_blob.h"
#include "member_installer.h"
#include "core/executing_context.h"

namespace kraken {

static JSValue arrayBuffer(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {

}

static JSValue slice(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {

}

static JSValue text(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {

}

static JSValue sizeAttributeGetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {

}

static JSValue sizeAttributeSetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {

}

static JSValue typeAttributeGetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {

}

static JSValue typeAttributeSetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {

}


JSValue QJSBlob::constructorCallback(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv, int flags) {
//  if (argc == 0) {
//    auto* blob = Blob::create(ctx);
//    return blob->toQuickJS();
//  }
//
//  JSValue arrayValue = argv[0];
//  JSValue optionValue = JS_UNDEFINED;
//
//  if (argc > 1) {
//    optionValue = argv[1];
//  }
//
//  if (!JS_IsArray(ctx, arrayValue)) {
//    return JS_ThrowTypeError(ctx, "Failed to construct 'Blob': The provided value cannot be converted to a sequence");
//  }
//
//  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
//  BlobBuilder builder;
//
//  if (argc == 1 || JS_IsUndefined(optionValue)) {
//    builder.append(*context, arrayValue);
//    auto* blob = Blob::create(ctx, builder.finalize());
//    return blob->toQuickJS();
//  }
//
//  if (!JS_IsObject(optionValue)) {
//    return JS_ThrowTypeError(ctx,
//                             "Failed to construct 'Blob': parameter 2 ('options') "
//                             "is not an object");
//  }
//
//  JSAtom mimeTypeKey = JS_NewAtom(ctx, "type");
//
//  JSValue mimeTypeValue = JS_GetProperty(ctx, optionValue, mimeTypeKey);
//  builder.append(*context, mimeTypeValue);
//  const char* cMineType = JS_ToCString(ctx, mimeTypeValue);
//  std::string mimeType = std::string(cMineType);
//
//  auto* blob = Blob::create(ctx, builder.finalize(), mimeType);
//
//  JS_FreeValue(ctx, mimeTypeValue);
//  JS_FreeCString(ctx, mimeType.c_str());
//  JS_FreeAtom(ctx, mimeTypeKey);
//
//  return blob->toQuickJS();
}

void QJSBlob::install(ExecutingContext* context) {
  installConstructor(context);
  installPrototypeMethods(context);
  installPrototypeProperties(context);
}

void QJSBlob::installConstructor(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = getWrapperTypeInfo();
  JSValue constructor = context->contextData()->constructorForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributeConfig {
    {"Blob", nullptr, nullptr, constructor}
  };
  MemberInstaller::installAttributes(context, context->global(), attributeConfig);
}

void QJSBlob::installPrototypeMethods(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = getWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributesConfig {
    {"size", sizeAttributeGetCallback, sizeAttributeSetCallback},
    {"type", typeAttributeGetCallback, typeAttributeSetCallback}
  };

  MemberInstaller::installAttributes(context, prototype, attributesConfig);
}

void QJSBlob::installPrototypeProperties(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = getWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    {"arrayBuffer", arrayBuffer, 0},
    {"slice", slice, 3},
    {"text", text, 0}
  };

  MemberInstaller::installFunctions(context, prototype, functionConfig);
}

}
