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

class Blob : public HostClass {
 public:
  static JSClassID kBlobClassID;
  OBJECT_INSTANCE(Blob);

  Blob() = delete;
  explicit Blob(ExecutionContext* context);

  JSValue instanceConstructor(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv) override;

  static JSValue arrayBuffer(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue slice(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);
  static JSValue text(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

 private:
  friend BlobInstance;
  DEFINE_PROTOTYPE_READONLY_PROPERTY(type);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(size);

  DEFINE_PROTOTYPE_FUNCTION(arrayBuffer, 0);
  DEFINE_PROTOTYPE_FUNCTION(slice, 3);
  DEFINE_PROTOTYPE_FUNCTION(text, 0);
};

class BlobInstance : public Instance {
 public:
  BlobInstance() = delete;
  explicit BlobInstance(Blob* blob) : Instance(blob, "Blob", nullptr, Blob::kBlobClassID, finalize){};
  explicit BlobInstance(Blob* blob, std::vector<uint8_t>&& data) : _size(data.size()), _data(std::move(data)), Instance(blob, "Blob", nullptr, Blob::kBlobClassID, finalize){};
  explicit BlobInstance(Blob* blob, std::vector<uint8_t>&& data, std::string& mime)
      : mimeType(mime), _size(data.size()), _data(std::move(data)), Instance(blob, "Blob", nullptr, Blob::kBlobClassID, finalize){};

  /// get an pointer of bytes data from JSBlob
  uint8_t* bytes();
  /// get bytes data's length
  int32_t size();

 private:
  size_t _size;
  std::string mimeType{""};
  std::vector<uint8_t> _data;
  friend BlobBuilder;
  friend Blob;

  static void finalize(JSRuntime* rt, JSValue val);
};

class BlobBuilder {
 public:
  void append(ExecutionContext& context, JSValue& value);
  void append(ExecutionContext& context, BlobInstance* blob);

  std::vector<uint8_t> finalize();

 private:
  friend Blob;
  std::vector<uint8_t> _data;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_BLOB_H
