/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKENBRIDGE_V8_IMPLEMENTATION_H
#define KRAKENBRIDGE_V8_IMPLEMENTATION_H

#include "jsa.h"
#include "libplatform/libplatform.h"
#include "v8.h"
#include "v8_instrumentation.h"
#include <atomic>
#include <memory>

namespace alibaba {
namespace jsa_v8 {

void initV8Engine(const char *current_directory);
std::unique_ptr<jsa::JSContext> createJSContext();

class V8Context : public jsa::JSContext {
public:
  V8Context();
  ~V8Context() override;

  jsa::Value evaluateJavaScript(const char *code, const std::string &sourceURL,
                                int startLine) override;

  jsa::Object global() override;

  std::string description() override;

  bool isInspectable() override;
  void *globalImpl() override;
  void setDescription(const std::string &desc);

  V8Instrumentation &instrumentation() override;

  // JSValueRef->JSValue (needs make.*Value so it must be member function)
  jsa::Value createValue(v8::Local<v8::Value> &value);

  // Value->JSValueRef (similar to above)
  v8::Local<v8::Value> valueRef(const jsa::Value &value);

  bool isValid() override;

  void reportError(jsa::JSError &error) override;

protected:
  // Symbol
  class V8SymbolValue final : public PointerValue {
    V8SymbolValue(v8::Isolate *isolate, const std::atomic<bool> &ctxInvalid,
                  v8::Local<v8::Symbol> sym
#ifndef NDEBUG
                  ,
                  std::atomic<intptr_t> &counter
#endif
    );
    void invalidate() override;

    v8::Isolate *isolate_;
    const std::atomic<bool> &ctxInvalid_;
    v8::Persistent<v8::Symbol> sym_;
#ifndef NDEBUG
    std::atomic<intptr_t> &counter_;
#endif
  protected:
    friend class V8Context;
  };

  // String
  class V8StringValue final : public PointerValue {
#ifndef NDEBUG
    V8StringValue(v8::Isolate *isolate, v8::Local<v8::String> str,
                  std::atomic<intptr_t> &counter);
#else
    V8StringValue(v8::Isolate *isolate, v8::Local<v8::String> string);
#endif
    void invalidate() override;

    v8::Persistent<v8::String> str_;
    v8::Isolate *isolate_;
#ifndef NDEBUG
    std::atomic<intptr_t> &counter_;
#endif
  protected:
    friend class V8Context;
  };

  // Object
  template <typename T> class V8ObjectValue final : public PointerValue {
    V8ObjectValue(v8::Isolate *isolate, const std::atomic<bool> &ctxInvalid,
                  v8::Local<v8::Object> &obj, T *privateData
#ifndef NDEBUG
                  ,
                  std::atomic<intptr_t> &counter
#endif
    );

    void invalidate() override;

    // recycle privateData's memory when javascript Object is finalized (prepared
    // for garbage collection).
    static void finalize(const v8::WeakCallbackInfo<T> &data);

    v8::Isolate *isolate_;
    v8::Persistent<v8::Object> obj_;
    const std::atomic<bool> &ctxInvalid_;
    T *privateData_;
#ifndef NDEBUG
    std::atomic<intptr_t> &counter_;
#endif
  protected:
    friend class V8Context;
  };

  PointerValue *cloneSymbol(const JSContext::PointerValue *pv) override;
  PointerValue *cloneString(const JSContext::PointerValue *pv) override;
  PointerValue *cloneObject(const JSContext::PointerValue *pv) override;
  PointerValue *clonePropNameID(const JSContext::PointerValue *pv) override;
  jsa::PropNameID createPropNameIDFromAscii(const char *str,
                                            size_t length) override;
  jsa::PropNameID createPropNameIDFromUtf8(const uint8_t *utf8,
                                           size_t length) override;
  jsa::PropNameID createPropNameIDFromString(const jsa::String &str) override;
  std::string utf8(const jsa::PropNameID &) override;
  bool compare(const jsa::PropNameID &, const jsa::PropNameID &) override;
  std::string symbolToString(const jsa::Symbol &) override;
  jsa::String createStringFromAscii(const char *str, size_t length) override;
  jsa::String createStringFromUtf8(const uint8_t *utf8, size_t length) override;
  std::string utf8(const jsa::String &) override;
  jsa::Object createObject() override;
  jsa::Object createObject(std::shared_ptr<jsa::HostObject> ho) override;
  virtual std::shared_ptr<jsa::HostObject>
  getHostObject(const jsa::Object &) override;
  jsa::HostFunctionType &getHostFunction(const jsa::Function &) override;
  jsa::Value getProperty(const jsa::Object &, const jsa::String &name) override;
  jsa::Value getProperty(const jsa::Object &,
                         const jsa::PropNameID &name) override;
  bool hasProperty(const jsa::Object &, const jsa::String &name) override;
  bool hasProperty(const jsa::Object &, const jsa::PropNameID &name) override;
  void setPropertyValue(jsa::Object &, const jsa::String &name,
                        const jsa::Value &value) override;
  void setPropertyValue(jsa::Object &, const jsa::PropNameID &name,
                        const jsa::Value &value) override;
  bool isArray(const jsa::Object &) const override;
  bool isArrayBuffer(const jsa::Object &) const override;
  bool isArrayBufferView(const jsa::Object &) const override;
  bool isFunction(const jsa::Object &) const override;
  bool isHostObject(const jsa::Object &) const override;
  bool isHostFunction(const jsa::Function &) const override;
  jsa::Array getPropertyNames(const jsa::Object &) override;
  jsa::WeakObject createWeakObject(const jsa::Object &) override;
  jsa::Value lockWeakObject(const jsa::WeakObject &) override;
  jsa::Array createArray(size_t length) override;
  jsa::ArrayBuffer createArrayBuffer(uint8_t* data, size_t length, jsa::ArrayBufferDeallocator<uint8_t> deallocator) override;
  size_t size(const jsa::Array &) override;
  size_t size(const jsa::ArrayBuffer &) override;
  size_t size(const jsa::ArrayBufferView&) override;
  void *data(const jsa::ArrayBuffer &) override;
  void *data(const jsa::ArrayBufferView &) override;
  jsa::ArrayBufferViewType arrayBufferViewType(const jsa::ArrayBufferView &) override;
  jsa::Value getValueAtIndex(const jsa::Array &, size_t i) override;
  void setValueAtIndexImpl(jsa::Array &, size_t i,
                           const jsa::Value &value) override;
  jsa::Function
  createFunctionFromHostFunction(const jsa::PropNameID &name,
                                 unsigned int paramCount,
                                 jsa::HostFunctionType func) override;
  jsa::Value call(const jsa::Function &, const jsa::Value &jsThis,
                  const jsa::Value *args, size_t count) override;
  jsa::Value callAsConstructor(const jsa::Function &, const jsa::Value *args,
                               size_t count) override;
  bool strictEquals(const jsa::Symbol &a, const jsa::Symbol &b) const override;
  bool strictEquals(const jsa::String &a, const jsa::String &b) const override;
  bool strictEquals(const jsa::Object &a, const jsa::Object &b) const override;
  bool instanceOf(const jsa::Object &o, const jsa::Function &f) override;

private:
  // Basically convenience casts
  v8::Local<v8::Symbol> symbolRef(const jsa::Symbol &str) const;
  v8::Local<v8::String> stringRef(const jsa::String &str) const;
  v8::Local<v8::String> stringRef(const jsa::PropNameID &sym) const;
  v8::Local<v8::Object> objectRef(const jsa::Object &obj) const;

  // Factory methods for creating String/Object
  jsa::Symbol createSymbol(v8::Local<v8::Symbol> symbol) const;
  jsa::String createString(v8::Local<v8::String> string) const;
  jsa::PropNameID createPropNameID(v8::Local<v8::String> string);
  jsa::Object createObject(v8::Local<v8::Object> &object) const;
  template <typename T>
  jsa::Object createObject(v8::Local<v8::Object> &object, T *privateData) const;

  // Used by factory methods and clone methods
  jsa::JSContext::PointerValue *
  makeSymbolValue(v8::Local<v8::Symbol> sym) const;
  jsa::JSContext::PointerValue *
  makeStringValue(v8::Local<v8::String> value) const;
  template <typename T>
  jsa::JSContext::PointerValue *makeObjectValue(v8::Local<v8::Object> &obj,
                                                T *privateData) const;

  v8::Isolate *_isolate;
  v8::Persistent<v8::Context> _context;
  v8::Persistent<v8::Object> _global;
  std::atomic<bool> ctxInvalid_;
  std::unique_ptr<V8Instrumentation> inst;

#ifndef NDEBUG
  mutable std::atomic<intptr_t> objectCounter_;
  mutable std::atomic<intptr_t> symbolCounter_;
  mutable std::atomic<intptr_t> stringCounter_;
#endif
};

} // namespace jsa_v8
} // namespace alibaba

#endif // KRAKENBRIDGE_V8_IMPLEMENTATION_H
