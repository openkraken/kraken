/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BLOB_H
#define KRAKENBRIDGE_BLOB_H

#include "bindings/qjs/host_class.h"

namespace kraken::binding::qjs {

class BlobBuilder;
class BlobInstance;

void bindBlob(std::unique_ptr<ExecutionContext>& context);

class Blob : public GarbageCollected<Blob> {
 public:
  static JSClassID classID;
  static Blob* create(JSContext* ctx);
  static Blob* create(JSContext* ctx, std::vector<uint8_t>&& data);
  static Blob* create(JSContext* ctx, std::vector<uint8_t>&& data, std::string& mime);
  static JSValue constructor(ExecutionContext* context);
  static JSValue prototype(ExecutionContext* context);

  Blob() {};
  Blob(std::vector<uint8_t>&& data): _size(data.size()), _data(std::move(data)) {};
  Blob(std::vector<uint8_t>&& data, std::string& mime): mimeType(mime), _size(data.size()), _data(std::move(data)) {};

  DEFINE_FUNCTION(arrayBuffer);
  DEFINE_FUNCTION(slice);
  DEFINE_FUNCTION(text);

  /// get an pointer of bytes data from JSBlob
  uint8_t* bytes();
  /// get bytes data's length
  int32_t size();

  DEFINE_PROTOTYPE_READONLY_PROPERTY(type);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(size);

  void trace(JSRuntime *rt, JSValue val, JS_MarkFunc *mark_func) const override;
  void dispose() const override;

 private:
  size_t _size;
  std::string mimeType;
  std::vector<uint8_t> _data;
  friend BlobBuilder;
};

class BlobBuilder {
 public:
  void append(ExecutionContext& context, JSValue& value);
  void append(ExecutionContext& context, Blob* blob);

  std::vector<uint8_t> finalize();

 private:
  friend Blob;
  std::vector<uint8_t> _data;
};

auto blobCreator = [](JSContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) -> JSValue {
  if (argc == 0) {
    auto* blob = Blob::create(ctx);
    return blob->toQuickJS();
  }

  JSValue arrayValue = argv[0];
  JSValue optionValue = JS_UNDEFINED;

  if (argc > 1) {
    optionValue = argv[1];
  }

  if (!JS_IsArray(ctx, arrayValue)) {
    return JS_ThrowTypeError(ctx, "Failed to construct 'Blob': The provided value cannot be converted to a sequence");
  }

  auto* context = static_cast<ExecutionContext*>(JS_GetContextOpaque(ctx));
  BlobBuilder builder;

  if (argc == 1 || JS_IsUndefined(optionValue)) {
    builder.append(*context, arrayValue);
    auto* blob = Blob::create(ctx, builder.finalize());
    return blob->toQuickJS();
  }

  if (!JS_IsObject(optionValue)) {
    return JS_ThrowTypeError(ctx,
                             "Failed to construct 'Blob': parameter 2 ('options') "
                             "is not an object");
  }

  JSAtom mimeTypeKey = JS_NewAtom(ctx, "type");

  JSValue mimeTypeValue = JS_GetProperty(ctx, optionValue, mimeTypeKey);
  builder.append(*context, mimeTypeValue);
  const char* cMineType = JS_ToCString(ctx, mimeTypeValue);
  std::string mimeType = std::string(cMineType);

  auto* blob = Blob::create(ctx, builder.finalize(), mimeType);

  JS_FreeValue(ctx, mimeTypeValue);
  JS_FreeCString(ctx, mimeType.c_str());
  JS_FreeAtom(ctx, mimeTypeKey);

  return blob->toQuickJS();
};

const WrapperTypeInfo blobTypeInfo = {
    "Blob",
    nullptr,
    blobCreator
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_BLOB_H
