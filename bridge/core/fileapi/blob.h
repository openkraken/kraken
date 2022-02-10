/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BLOB_H
#define KRAKENBRIDGE_BLOB_H

#include "bindings/qjs/garbage_collected.h"
#include "bindings/qjs/macros.h"
#include <string>
#include <vector>

namespace kraken {

class BlobBuilder;

class Blob : public GarbageCollected<Blob> {
 public:
  static JSClassID classID;
  static Blob* create(JSContext* ctx);
  static Blob* create(JSContext* ctx, std::vector<uint8_t>&& data);
  static Blob* create(JSContext* ctx, std::vector<uint8_t>&& data, std::string& mime);
  static JSValue constructor(ExecutingContext* context);
  static JSValue prototype(ExecutingContext* context);

  Blob(){};
  Blob(std::vector<uint8_t>&& data) : _size(data.size()), _data(std::move(data)){};
  Blob(std::vector<uint8_t>&& data, std::string& mime) : mimeType(mime), _size(data.size()), _data(std::move(data)){};

  /// get an pointer of bytes data from JSBlob
  uint8_t* bytes();
  /// get bytes data's length
  int32_t size();

  DEFINE_PROTOTYPE_READONLY_PROPERTY(type);
  DEFINE_PROTOTYPE_READONLY_PROPERTY(size);

  void trace(GCVisitor* visitor) const override;
  void dispose() const override;

 private:
  size_t _size;
  std::string mimeType;
  std::vector<uint8_t> _data;
  friend BlobBuilder;
};

class BlobBuilder {
 public:
  void append(ExecutingContext& context, JSValue& value);
  void append(ExecutingContext& context, Blob* blob);

  std::vector<uint8_t> finalize();

 private:
  friend Blob;
  std::vector<uint8_t> _data;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BLOB_H
