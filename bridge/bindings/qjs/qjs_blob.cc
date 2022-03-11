/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_blob.h"
#include "member_installer.h"
#include "core/executing_context.h"
#include "core/fileapi/blob.h"
#include "converter.h"

namespace kraken {


//IMPL_PROPERTY_GETTER(Blob, type)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));
//  return JS_NewString(blob->m_ctx, blob->mimeType.empty() ? "" : blob->mimeType.c_str());
//}
//
//IMPL_PROPERTY_GETTER(Blob, size)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  auto* blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));
//  return JS_NewFloat64(blob->m_ctx, blob->_size);
//}
//
//IMPL_FUNCTION(Blob, arrayBuffer)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  JSValue resolving_funcs[2];
//  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);
//
//  auto blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));
//
//  JS_DupValue(ctx, blob->jsObject);
//
//  auto* promiseContext = new PromiseContext{blob, blob->context(), resolving_funcs[0], resolving_funcs[1], promise};
//  auto callback = [](void* callbackContext, int32_t contextId, const char* errmsg) {
//    if (!isContextValid(contextId))
//      return;
//    auto* promiseContext = static_cast<PromiseContext*>(callbackContext);
//    auto* blob = static_cast<Blob*>(promiseContext->data);
//    JSContext* ctx = blob->m_ctx;
//
//    JSValue arrayBuffer = JS_NewArrayBuffer(
//        ctx, blob->bytes(), blob->size(), [](JSRuntime* rt, void* opaque, void* ptr) {}, nullptr, false);
//    JSValue arguments[] = {arrayBuffer};
//    JSValue returnValue = JS_Call(ctx, promiseContext->resolveFunc, blob->context()->global(), 1, arguments);
//    JS_FreeValue(ctx, returnValue);
//
//    blob->context()->drainPendingPromiseJobs();
//
//    if (JS_IsException(returnValue)) {
//      blob->context()->handleException(&returnValue);
//      return;
//    }
//
//    JS_FreeValue(ctx, promiseContext->resolveFunc);
//    JS_FreeValue(ctx, promiseContext->rejectFunc);
//    JS_FreeValue(ctx, arrayBuffer);
//    JS_FreeValue(ctx, blob->jsObject);
//    list_del(&promiseContext->link);
//    delete promiseContext;
//  };
//  list_add_tail(&promiseContext->link, &blob->context()->promise_job_list);
//
//  // TODO: remove setTimeout
//  getDartMethod()->setTimeout(promiseContext, blob->context()->getContextId(), callback, 0);
//
//  return promise;
//}
//
//IMPL_FUNCTION(Blob, slice)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  JSValue startValue = argv[0];
//  JSValue endValue = argv[1];
//  JSValue contentTypeValue = argv[2];
//
//  auto* blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));
//  int32_t start = 0;
//  int32_t end = blob->_data.size();
//  std::string mimeType = blob->mimeType;
//
//  if (argc > 0 && !JS_IsUndefined(startValue)) {
//    JS_ToInt32(ctx, &start, startValue);
//  }
//
//  if (argc > 1 && !JS_IsUndefined(endValue)) {
//    JS_ToInt32(ctx, &end, endValue);
//  }
//
//  if (argc > 2 && !JS_IsUndefined(contentTypeValue)) {
//    const char* cmimeType = JS_ToCString(ctx, contentTypeValue);
//    mimeType = std::string(cmimeType);
//    JS_FreeCString(ctx, mimeType.c_str());
//  }
//
//  if (start == 0 && end == blob->_data.size()) {
//    auto* newBlob = Blob::create(ctx, std::move(blob->_data), mimeType);
//    return newBlob->toQuickJS();
//  }
//  std::vector<uint8_t> newData;
//  newData.reserve(blob->_data.size() - (end - start));
//  newData.insert(newData.begin(), blob->_data.begin() + start, blob->_data.end() - (blob->_data.size() - end));
//
//  auto* newBlob = Blob::create(ctx, std::move(newData), mimeType);
//  return newBlob->toQuickJS();
//}
//
//IMPL_FUNCTION(Blob, text)(JSContext* ctx, JSValue this_val, int argc, JSValue* argv) {
//  JSValue resolving_funcs[2];
//  JSValue promise = JS_NewPromiseCapability(ctx, resolving_funcs);
//
//  auto blob = static_cast<Blob*>(JS_GetOpaque(this_val, Blob::classID));
//  JS_DupValue(ctx, blob->jsObject);
//
//  auto* promiseContext = new PromiseContext{blob, blob->context(), resolving_funcs[0], resolving_funcs[1], promise};
//  auto callback = [](void* callbackContext, int32_t contextId, const char* errmsg) {
//    if (!isContextValid(contextId))
//      return;
//
//    auto* promiseContext = static_cast<PromiseContext*>(callbackContext);
//    auto* blob = static_cast<Blob*>(promiseContext->data);
//    JSContext* ctx = blob->m_ctx;
//
//    JSValue text = JS_NewStringLen(ctx, reinterpret_cast<const char*>(blob->bytes()), blob->size());
//    JSValue arguments[] = {text};
//    JSValue returnValue = JS_Call(ctx, promiseContext->resolveFunc, blob->context()->global(), 1, arguments);
//    JS_FreeValue(ctx, returnValue);
//
//    blob->context()->drainPendingPromiseJobs();
//
//    if (JS_IsException(returnValue)) {
//      blob->context()->handleException(&returnValue);
//      return;
//    }
//
//    JS_FreeValue(ctx, promiseContext->resolveFunc);
//    JS_FreeValue(ctx, promiseContext->rejectFunc);
//    JS_FreeValue(ctx, text);
//    JS_FreeValue(ctx, blob->jsObject);
//    list_del(&promiseContext->link);
//    delete promiseContext;
//  };
//  list_add_tail(&promiseContext->link, &blob->context()->promise_job_list);
//
//  getDartMethod()->setTimeout(promiseContext, blob->context()->getContextId(), callback, 0);
//
//  return promise;
//}

const WrapperTypeInfo& Blob::wrapper_type_info_ = QJSBlob::m_wrapperTypeInfo;

//const WrapperTypeInfo Blob::wrapper_type_info_ = QJSBlob::m_wrapperTypeInfo;

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


JSValue QJSBlob::ConstructorCallback(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv, int flags) {
  if (argc == 0) {
    auto* blob = Blob::create(ctx);
    return blob->ToQuickJS();
  }



//  JSValue arrayValue =  argv[0];
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
//  auto* context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
//  BlobBuilder builder;
//
//  if (argc == 1 || JS_IsUndefined(optionValue)) {
//    builder.append(*context, ScriptValue(ctx, arrayValue));
//    auto* blob = Blob::create(ctx, builder.finalize());
//    return blob->toQuickJS();
//  }
//
//  if (!JS_IsObject(optionValue)) {
//    return JS_ThrowTypeError(ctx,
//                             "Failed to construct 'Blob': parameter 2 ('options') "
//                             "is not an object");
//  }

//  ScriptAtom mineType = ScriptAtom(ctx, "type");
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
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue constructor = context->contextData()->constructorForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributeConfig {
    {"Blob", nullptr, nullptr, constructor}
  };
  MemberInstaller::InstallAttributes(context, context->Global(), attributeConfig);
}

void QJSBlob::installPrototypeMethods(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributesConfig {
    {"size", sizeAttributeGetCallback, sizeAttributeSetCallback},
    {"type", typeAttributeGetCallback, typeAttributeSetCallback}
  };

  MemberInstaller::InstallAttributes(context, prototype, attributesConfig);
}

void QJSBlob::installPrototypeProperties(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    {"arrayBuffer", arrayBuffer, 0},
    {"slice", slice, 3},
    {"text", text, 0}
  };

  MemberInstaller::InstallFunctions(context, prototype, functionConfig);
}

}
