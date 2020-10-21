/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKENBRIDGE_BLOB_H
#define KRAKENBRIDGE_BLOB_H

#include "bindings/jsc/js_context.h"
#include <memory>
#include <utility>
#include <vector>

#define JSBlobName "Blob"

namespace kraken::binding::jsc {

void bindBlob(std::unique_ptr<JSContext> &context);

class JSBlob;

class BlobBuilder {
public:
  void append(JSContext &context, const JSValueRef value, JSValueRef *exception);
  void append(JSContext &context, JSBlob *blob);
  void append(JSContext &context, JSStringRef text);

  std::vector<uint8_t> finalize();

private:
  friend JSBlob;
  std::vector<uint8_t> _data;
};

class JSBlob : public HostObject {
public:
  /// the new Blob constructor, return Blob instance.
  static JSValueRef constructor(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef slice(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                          const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef text(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef arrayBuffer(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception);

  JSBlob() = delete;
  JSBlob(JSContext *context) : _size(0), HostObject(context, JSBlobName){};
  JSBlob(JSContext *context, std::vector<uint8_t> &&data)
    : _size(data.size()), _data(std::move(data)), HostObject(context, JSBlobName){};
  JSBlob(JSContext *context, std::vector<uint8_t> &&data, std::string mime)
    : mimeType(std::move(mime)), _size(data.size()), HostObject(context, JSBlobName){};

  /// get an pointer of bytes data from JSBlob
  uint8_t *bytes();

  /// get bytes data's length
  int32_t size();

  JSValueRef getProperty(JSStringRef name, JSValueRef *exception) override;

private:
  friend BlobBuilder;
  size_t _size;
  std::string mimeType;
  std::vector<uint8_t> _data;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_BLOB_H
