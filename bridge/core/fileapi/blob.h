/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BLOB_H
#define KRAKENBRIDGE_BLOB_H

#include <string>
#include <vector>
#include "bindings/qjs/macros.h"
#include "bindings/qjs/qjs_blob.h"
#include "bindings/qjs/script_wrappable.h"

namespace kraken {

class BlobBuilder;

class Blob : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();
 public:
  static Blob* create(JSContext* ctx);
  static Blob* create(JSContext* ctx, std::vector<uint8_t>&& data);
  static Blob* create(JSContext* ctx, std::vector<uint8_t>&& data, std::string& mime);

  Blob() = delete;
  explicit Blob(JSContext* ctx);
  explicit Blob(JSContext* ctx, std::vector<uint8_t>&& data) : _size(data.size()), _data(std::move(data)), ScriptWrappable(ctx) {};
  explicit Blob(JSContext* ctx, std::vector<uint8_t>&& data, std::string& mime) : mimeType(mime), _size(data.size()), _data(std::move(data)), ScriptWrappable(ctx){};

  /// get an pointer of bytes data from JSBlob
  uint8_t* bytes();
  /// get bytes data's length
  int32_t size();

  void trace(GCVisitor* visitor) const override;
  void dispose() const override;

 private:
  size_t _size;
  std::string mimeType;
  std::vector<uint8_t> _data;
  friend BlobBuilder;
  friend QJSBlob;
};

class BlobBuilder {
 public:
  void append(ExecutingContext& context, ScriptValue& value);
  void append(ExecutingContext& context, Blob* blob);

  std::vector<uint8_t> finalize();

 private:
  friend Blob;
  std::vector<uint8_t> _data;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BLOB_H
