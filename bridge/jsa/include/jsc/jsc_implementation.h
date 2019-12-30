/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef JSA_IMPLEMENTATION_JSC_CONTEXT_H_
#define JSA_IMPLEMENTATION_JSC_CONTEXT_H_

#include "JavaScriptCore/JavaScript.h"
#include <atomic>
#include <cstdlib>
#include <memory>
#include <mutex>
#include <queue>
#include <sstream>

namespace alibaba {
namespace jsc {

namespace detail {
// 参数转换。
// jsa::Values* -> JSValueRef*
class ArgsConverter;
} // namespace detail

class JSCContext;

class JSCContext : public jsa::JSContext {
public:
  // Creates new context in new context group
  JSCContext();
  // Retains ctx
  JSCContext(JSGlobalContextRef ctx);
  ~JSCContext();

  jsa::Value evaluateJavaScript(const char *code, const std::string &sourceURL,
                                int startLine) override;
  jsa::Object global() override;

  std::string description() override;

  bool isInspectable() override;

  void *globalImpl() override;

  void setDescription(const std::string &desc);

  // Please don't use the following two functions, only exposed for
  // integration efforts.
  JSGlobalContextRef getContext() { return ctx_; }

  // JSValueRef->JSValue (needs make.*Value so it must be member function)
  jsa::Value createValue(JSValueRef value) const;

  // Value->JSValueRef (similar to above)
  JSValueRef valueRef(const jsa::Value &value);

protected:
  friend class detail::ArgsConverter;

  /////////////////////////////// JavaScriptCore
  ///指针类型声明///////////////////////////////////////////////
  //
  //  JSA中，指针类型需要实现jsa::PointerValue接口。
  //  JS类型Symobol/Object(Function/Array/ArrayBuffer)/String为指针类型。
  //
  //

  // Symbol
  class JSCSymbolValue final : public PointerValue {
#ifndef NDEBUG
    JSCSymbolValue(JSGlobalContextRef ctx, const std::atomic<bool> &ctxInvalid,
                   JSValueRef sym, std::atomic<intptr_t> &counter);
#else
    JSCSymbolValue(JSGlobalContextRef ctx, const std::atomic<bool> &ctxInvalid,
                   JSValueRef sym);
#endif
    void invalidate() override;

    JSGlobalContextRef ctx_;
    const std::atomic<bool> &ctxInvalid_;
    // There is no C type in the JSC API to represent Symbol, so this stored
    // a JSValueRef which contains the Symbol.
    JSValueRef sym_;
#ifndef NDEBUG
    std::atomic<intptr_t> &counter_;
#endif
  protected:
    friend class JSCContext;
  };

  // String
  class JSCStringValue final : public PointerValue {
#ifndef NDEBUG
    JSCStringValue(JSStringRef str, std::atomic<intptr_t> &counter);
#else
    JSCStringValue(JSStringRef str);
#endif
    void invalidate() override;

    JSStringRef str_;
#ifndef NDEBUG
    std::atomic<intptr_t> &counter_;
#endif
  protected:
    friend class JSCContext;
  };

  // Object
  class JSCObjectValue final : public PointerValue {
    JSCObjectValue(JSGlobalContextRef ctx, const std::atomic<bool> &ctxInvalid,
                   JSObjectRef obj
#ifndef NDEBUG
                   ,
                   std::atomic<intptr_t> &counter
#endif
    );

    void invalidate() override;

    JSGlobalContextRef ctx_;
    const std::atomic<bool> &ctxInvalid_;
    JSObjectRef obj_;
#ifndef NDEBUG
    std::atomic<intptr_t> &counter_;
#endif
  protected:
    friend class JSCContext;
  };

  /////////////////////////////////////////////////////////////////////////////////////////////////////////

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
  bool isFunction(const jsa::Object &) const override;
  bool isHostObject(const jsa::Object &) const override;
  bool isHostFunction(const jsa::Function &) const override;
  jsa::Array getPropertyNames(const jsa::Object &) override;

  jsa::WeakObject createWeakObject(const jsa::Object &) override;
  jsa::Value lockWeakObject(const jsa::WeakObject &) override;

  jsa::Array createArray(size_t length) override;
  size_t size(const jsa::Array &) override;
  size_t size(const jsa::ArrayBuffer &) override;
  uint8_t *data(const jsa::ArrayBuffer &) override;
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
  static JSValueRef symbolRef(const jsa::Symbol &str);
  static JSStringRef stringRef(const jsa::String &str);
  static JSStringRef stringRef(const jsa::PropNameID &sym);
  static JSObjectRef objectRef(const jsa::Object &obj);

  // Factory methods for creating String/Object
  jsa::Symbol createSymbol(JSValueRef symbolRef) const;
  jsa::String createString(JSStringRef stringRef) const;
  jsa::PropNameID createPropNameID(JSStringRef stringRef);
  jsa::Object createObject(JSObjectRef objectRef) const;

  // Used by factory methods and clone methods
  jsa::JSContext::PointerValue *makeSymbolValue(JSValueRef sym) const;
  jsa::JSContext::PointerValue *makeStringValue(JSStringRef str) const;
  jsa::JSContext::PointerValue *makeObjectValue(JSObjectRef obj) const;

  void checkException(JSValueRef exc);
  void checkException(JSValueRef res, JSValueRef exc);
  void checkException(JSValueRef exc, const char *msg);
  void checkException(JSValueRef res, JSValueRef exc, const char *msg);

  JSGlobalContextRef ctx_;
  std::atomic<bool> ctxInvalid_;
  std::string desc_;
#ifndef NDEBUG
  mutable std::atomic<intptr_t> objectCounter_;
  mutable std::atomic<intptr_t> symbolCounter_;
  mutable std::atomic<intptr_t> stringCounter_;
#endif
}; // JSCContext

// 工厂函数。创建JSC运行时。
std::unique_ptr<jsa::JSContext> createJSContext();
} // namespace jsc
} // namespace alibaba

#endif // JSA_IMPLEMENTATION_JSC_CONTEXT_H_
