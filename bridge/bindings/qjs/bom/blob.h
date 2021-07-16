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

void bindBlob(std::unique_ptr<JSContext> &context);

class Blob : public HostClass {
public:
  OBJECT_INSTANCE(Blob);

  Blob() = delete;
  explicit Blob(JSContext *context);

  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  static JSValue arrayBuffer(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue slice(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue text(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

private:
  DEFINE_HOST_CLASS_PROPERTY(2, type, size);
  friend BlobInstance;

  ObjectFunction m_arrayBuffer{m_context, m_prototypeObject, "arrayBuffer", arrayBuffer, 0};
  ObjectFunction m_slice{m_context, m_prototypeObject, "slice", slice, 3};
  ObjectFunction m_text{m_context, m_prototypeObject, "text", text, 0};
};

class BlobInstance : public Instance {
public:
  BlobInstance() = delete;
  explicit BlobInstance(Blob *blob): Instance(blob, "Blob") {};
  explicit BlobInstance(Blob *blob, std::vector<uint8_t> &&data)
      : _size(data.size()), _data(std::move(data)), Instance(blob, "Blob"){};
  explicit BlobInstance(Blob *blob, std::vector<uint8_t> &&data, std::string &mime)
      : mimeType(mime), _size(data.size()), _data(std::move(data)), Instance(blob, "Blob"){};

  /// get an pointer of bytes data from JSBlob
  uint8_t *bytes();
  /// get bytes data's length
  int32_t size();
private:
  size_t _size;
  std::string mimeType{""};
  std::vector<uint8_t> _data;
  friend BlobBuilder;
  friend Blob;
};

class BlobBuilder {
public:
  void append(JSContext &context, JSValue &value);
  void append(JSContext &context, BlobInstance *blob);

  std::vector<uint8_t> finalize();

private:
  friend Blob;
  std::vector<uint8_t> _data;
};

}

#endif // KRAKENBRIDGE_BLOB_H
