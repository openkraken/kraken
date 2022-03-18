/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BLOB_H
#define KRAKENBRIDGE_BLOB_H

#include <string>
#include <vector>
#include "bindings/qjs/macros.h"
#include "bindings/qjs/script_wrappable.h"
#include "blob_part.h"
#include "blob_property_bag.h"

namespace kraken {

class Blob : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static Blob* Create(ExecutingContext* context);
  static Blob* Create(ExecutingContext* context, std::vector<std::shared_ptr<BlobPart>> data, ExceptionState& exception_state);
  static Blob* Create(ExecutingContext* context,
                      std::vector<std::shared_ptr<BlobPart>> data,
                      std::shared_ptr<BlobPropertyBag> property,
                      ExceptionState& exception_state);

  Blob() = delete;
  explicit Blob(JSContext* ctx) : ScriptWrappable(ctx){};
  explicit Blob(JSContext* ctx, std::vector<uint8_t>&& data) : _size(data.size()), _data(std::move(data)), ScriptWrappable(ctx){};
  explicit Blob(JSContext* ctx, std::vector<uint8_t>&& data, std::string& mime) : mime_type_(mime), _size(data.size()), _data(std::move(data)), ScriptWrappable(ctx){};

  /// get an pointer of bytes data from JSBlob
  uint8_t* bytes();
  /// get bytes data's length
  int32_t size();
  std::string type();

  Blob* slice(ExceptionState& exception_state);
  Blob* slice(int64_t start, ExceptionState* exception_state);

  const char* GetHumanReadableName() const override;
  void Trace(GCVisitor* visitor) const override;
  void Dispose() const override;

 private:
  size_t _size;
  std::string mime_type_;
  std::vector<uint8_t> _data;
  friend QJSBlob;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BLOB_H
