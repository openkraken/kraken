/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BLOB_H
#define KRAKENBRIDGE_BLOB_H

#include <string>
#include <vector>
#include "array_buffer_data.h"
#include "bindings/qjs/macros.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_wrappable.h"
#include "blob_part.h"
#include "blob_property_bag.h"

namespace kraken {

class Blob : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static Blob* Create(ExecutingContext* context);
  static Blob* Create(ExecutingContext* context, std::vector<std::shared_ptr<BlobPart>>& data, ExceptionState& exception_state);
  static Blob* Create(ExecutingContext* context, std::vector<std::shared_ptr<BlobPart>>& data, std::shared_ptr<BlobPropertyBag> property, ExceptionState& exception_state);

  Blob() = delete;
  explicit Blob(JSContext* ctx) : ScriptWrappable(ctx){};
  explicit Blob(JSContext* ctx, std::vector<std::shared_ptr<BlobPart>>& data) : ScriptWrappable(ctx) { PopulateBlobData(data); };
  explicit Blob(JSContext* ctx, std::vector<std::shared_ptr<BlobPart>>& data, std::shared_ptr<BlobPropertyBag>& property) : mime_type_(property->type()), ScriptWrappable(ctx) {
    PopulateBlobData(data);
  };

  void AppendText(const std::string& string);
  void AppendBytes(uint8_t* buffer, uint32_t length);

  /// get an pointer of bytes data from JSBlob
  uint8_t* bytes();
  /// get bytes data's length
  int32_t size();
  std::string type();

  ScriptPromise arrayBuffer(ExceptionState& exception_state);
  ScriptPromise text(ExceptionState& exception_state);

  Blob* slice(ExceptionState& exception_state);
  Blob* slice(int64_t start, ExceptionState& exception_state);
  Blob* slice(int64_t start, int64_t end, ExceptionState& exception_state);
  Blob* slice(int64_t start, int64_t end, std::unique_ptr<NativeString>& content_type, ExceptionState& exception_state);

  std::string StringResult();
  ArrayBufferData ArrayBufferResult();

  const char* GetHumanReadableName() const override;
  void Trace(GCVisitor* visitor) const override;
  void Dispose() const override;

 protected:
  void PopulateBlobData(std::vector<std::shared_ptr<BlobPart>>& data);

 private:
  std::string mime_type_;
  std::vector<uint8_t> _data;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BLOB_H
