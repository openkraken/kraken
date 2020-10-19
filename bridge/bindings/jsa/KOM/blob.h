/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKENBRIDGE_BLOB_H
#define KRAKENBRIDGE_BLOB_H

#include "jsa.h"
#include <memory>
#include <vector>

namespace kraken {
namespace binding {
namespace jsa {

using namespace alibaba::jsa;

void bindBlob(std::unique_ptr<JSContext> &context);

class JSBlob;

class BlobBuilder {
public:
  void append(JSContext &context, Value &);

  void append(JSContext &context, ArrayBuffer &&);

  void append(JSContext &context, ArrayBufferView &&);

  void append(JSContext &context, JSBlob &&);
  void append(JSContext &context, std::shared_ptr<JSBlob> blob);

  void append(JSContext &context, String &&text);

  std::vector<uint8_t> finalize();

private:
  friend JSBlob;
  std::vector<uint8_t> _data;
};

class JSBlob : public HostObject {
public:
  JSBlob() = delete;

  JSBlob(std::vector<uint8_t> &data) : _size(data.size()), _data(std::move(data)) {}

  JSBlob(std::vector<uint8_t> &&data) : _size(data.size()), _data(std::move(data)) {}

  JSBlob(std::vector<uint8_t> &&data, std::string &mime) : mimeType(mime), _size(data.size()), _data(std::move(data)) {}

  JSBlob(std::vector<uint8_t> &data, std::string &mime) : mimeType(mime), _size(data.size()), _data(std::move(data)) {}

  Value get(JSContext &, const PropNameID &name) override;

  void set(JSContext &, const PropNameID &name, const Value &value) override;

  /// get an pointer of bytes data from JSBlob
  uint8_t *bytes();

  /// get bytes data's length
  int32_t size();

  /// the new Blob constructor, return Blob instance.
  static Value constructor(JSContext &context, const Value &thisVal, const Value *args, size_t count);

  /// Returns a new Blob object containing the data in the specified range of
  /// bytes of the blob on which it's called.
  static Value slice(JSContext &context, const Value &thisVal, const Value *args, size_t count);

  /// Returns a promise that resolves with a USVString containing the entire contents of the blob interpreted as UTF-8
  /// text.
  static Value text(JSContext &context, const Value &thisVal, const Value *args, size_t count);

  static Value arrayBuffer(JSContext &context, const Value &thisVal, const Value *args, size_t count);

  std::vector<PropNameID> getPropertyNames(JSContext &context) override;

private:
  friend BlobBuilder;
  size_t _size;
  std::string mimeType;
  std::vector<uint8_t> _data;
};

}
} // namespace binding
} // namespace kraken

#endif // KRAKENBRIDGE_BLOB_H
