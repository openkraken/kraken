/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKENBRIDGE_BLOB_H
#define KRAKENBRIDGE_BLOB_H

#include "bindings/jsc/host_class.h"
#include "bindings/jsc/js_context_internal.h"
#include <memory>
#include <unordered_map>
#include <utility>
#include <vector>

#define JSBlobName "Blob"

namespace kraken::binding::jsc {

void bindBlob(std::unique_ptr<JSContext> &context);

class JSBlob;
class BlobBuilder;

class KRAKEN_EXPORT JSBlob : public HostClass {
public:
  static std::unordered_map<JSContext *, JSBlob *> instanceMap;
  static JSBlob *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class BlobInstance : public Instance {
  public:
    DEFINE_OBJECT_PROPERTY(Blob, 2, type, size);
    DEFINE_PROTOTYPE_OBJECT_PROPERTY(Blob, 4, stream, arrayBuffer, slice, text);

    BlobInstance() = delete;
    explicit BlobInstance(JSBlob *jsBlob) : _size(0), Instance(jsBlob){};
    explicit BlobInstance(JSBlob *jsBlob, std::vector<uint8_t> &&data)
      : _size(data.size()), _data(std::move(data)), Instance(jsBlob){};
    explicit BlobInstance(JSBlob *jsBlob, std::vector<uint8_t> &&data, std::string &mime)
      : mimeType(mime), _size(data.size()), _data(std::move(data)), Instance(jsBlob){};

    ~BlobInstance() override;

    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    /// get an pointer of bytes data from JSBlob
    uint8_t *bytes();

    /// get bytes data's length
    int32_t size();

  private:
    size_t _size;
    std::string mimeType{""};
    std::vector<uint8_t> _data;
    friend BlobBuilder;
    friend JSBlob;
  };
  struct BlobPromiseContext {
    BlobInstance *blobInstance;
  };

protected:
  friend BlobInstance;
  JSBlob() = delete;
  ~JSBlob();
  explicit JSBlob(JSContext *context) : HostClass(context, "Blob"){};

  static JSValueRef slice(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                          const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef text(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                         const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef arrayBuffer(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception);

  JSFunctionHolder m_arrayBuffer{context, prototypeObject, this, "arrayBuffer", arrayBuffer};
  JSFunctionHolder m_slice{context, prototypeObject, this, "slice", slice};
  JSFunctionHolder m_text{context, prototypeObject, this, "text", text};
};

class BlobBuilder {
public:
  void append(JSContext &context, const JSValueRef value, JSValueRef *exception);
  void append(JSContext &context, JSBlob::BlobInstance *blob);
  void append(JSContext &context, JSStringRef text);

  std::vector<uint8_t> finalize();

private:
  friend JSBlob;
  std::vector<uint8_t> _data;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_BLOB_H
