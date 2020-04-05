/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "jsc_implementation.h"

namespace alibaba {
namespace jsc {

/////////////////////////////////////////一些宏定义/////////////////////////////////////////////

#ifndef __has_builtin
#define __has_builtin(x) 0
#endif

#if __has_builtin(__builtin_expect) || defined(__GNUC__)
#define JSC_LIKELY(EXPR) __builtin_expect((bool)(EXPR), true)
#define JSC_UNLIKELY(EXPR) __builtin_expect((bool)(EXPR), false)
#else
#define JSC_LIKELY(EXPR) (EXPR)
#define JSC_UNLIKELY(EXPR) (EXPR)
#endif

#define JSC_ASSERT(x)                                                                                                  \
  do {                                                                                                                 \
    if (JSC_UNLIKELY(!!(x))) {                                                                                         \
      abort();                                                                                                         \
    }                                                                                                                  \
  } while (0)

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
// This takes care of watch and tvos (due to backwards compatibility in
// Availability.h
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
#define _JSC_FAST_IS_ARRAY
#endif
#endif
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_11
// Only one of these should be set for a build.  If somehow that's not
// true, this will be a compile-time error and it can be resolved when
// we understand why.
#define _JSC_FAST_IS_ARRAY
#endif
#endif

// JSStringRef utilities
namespace {
std::string JSStringToSTLString(JSStringRef str) {
  size_t maxBytes = JSStringGetMaximumUTF8CStringSize(str);
  std::vector<char> buffer(maxBytes);
  JSStringGetUTF8CString(str, buffer.data(), maxBytes);
  return std::string(buffer.data());
}

JSStringRef getLengthString() {
  static JSStringRef length = JSStringCreateWithUTF8CString("length");
  return length;
}

JSStringRef getNameString() {
  static JSStringRef name = JSStringCreateWithUTF8CString("name");
  return name;
}

JSStringRef getFunctionString() {
  static JSStringRef func = JSStringCreateWithUTF8CString("Function");
  return func;
}

#if !defined(_JSC_FAST_IS_ARRAY)
JSStringRef getArrayString() {
  static JSStringRef array = JSStringCreateWithUTF8CString("Array");
  return array;
}

JSStringRef getIsArrayString() {
  static JSStringRef isArray = JSStringCreateWithUTF8CString("isArray");
  return isArray;
}
#endif
} // namespace

// std::string utility
namespace {
std::string to_string(void *value) {
  std::ostringstream ss;
  ss << value;
  return ss.str();
}
} // namespace

JSCContext::JSCContext(jsa::JSExceptionHandler handler)
  : ctxInvalid_(false), _handler(handler)
#ifndef NDEBUG
    ,
    objectCounter_(0), stringCounter_(0)
#endif
{
  ctx_ = JSGlobalContextCreateInGroup(nullptr, nullptr);

  JSObjectRef global = JSContextGetGlobalObject(ctx_);
  JSStringRef globalName = JSStringCreateWithUTF8CString("global");
  JSObjectSetProperty(ctx_, global, globalName, global, kJSPropertyAttributeNone, nullptr);
}

JSCContext::~JSCContext() {
  // On shutting down and cleaning up: when JSC is actually torn down,
  // it calls JSC::Heap::lastChanceToFinalize internally which
  // finalizes anything left over.  But at this point,
  // JSValueUnprotect() can no longer be called.  We use an
  // atomic<bool> to avoid unsafe unprotects happening after shutdown
  // has started.
  ctxInvalid_ = true;
  JSGlobalContextRelease(ctx_);
#ifndef NDEBUG
  assert(objectCounter_ == 0 && "JSCContext destroyed with a dangling API object");
  assert(stringCounter_ == 0 && "JSCContext destroyed with a dangling API string");
#endif
}

jsa::Value JSCContext::evaluateJavaScript(const char *code, const std::string &sourceURL, int startLine) {

  // step1: 构造JSC source以及sourceURL
  JSStringRef sourceRef = JSStringCreateWithUTF8CString(code);
  JSStringRef sourceURLRef = nullptr;
  if (!sourceURL.empty()) {
    sourceURLRef = JSStringCreateWithUTF8CString(sourceURL.c_str());
  }

  // step2: 调用 JSC evaluateScript
  JSValueRef exc = nullptr; // exception
  JSValueRef res = JSEvaluateScript(ctx_, sourceRef, nullptr /*null means global*/, sourceURLRef, startLine, &exc);

  JSStringRelease(sourceRef);
  if (sourceURLRef) {
    JSStringRelease(sourceURLRef);
  }

  // step3: 查看是否有异常
  if (hasException(res, exc)) return jsa::Value::null();
  return createValue(res);
}

jsa::Object JSCContext::global() {
  return createObject(JSContextGetGlobalObject(ctx_));
}

void *JSCContext::globalImpl() {
  auto context = getContext();
  return context;
}

std::string JSCContext::description() {
  if (desc_.empty()) {
    desc_ = std::string("<JSCContext@") + to_string(this) + ">";
  }
  return desc_;
}

bool JSCContext::isInspectable() {
  return false;
}

bool JSCContext::isValid() {
  return !ctxInvalid_.load();
}

void JSCContext::reportError(jsa::JSError &error) {
  _handler(error);
}

namespace {

bool smellsLikeES6Symbol(JSGlobalContextRef ctx, JSValueRef ref) {
  // Empirically, an es6 Symbol is not an object, but its type is
  // object.  This makes no sense, but we'll run with it.
  return (!JSValueIsObject(ctx, ref) && JSValueGetType(ctx, ref) == kJSTypeObject);
}

} // namespace

JSCContext::JSCSymbolValue::JSCSymbolValue(JSGlobalContextRef ctx, const std::atomic<bool> &ctxInvalid, JSValueRef sym
#ifndef NDEBUG
                                           ,
                                           std::atomic<intptr_t> &counter
#endif
                                           )
  : ctx_(ctx), ctxInvalid_(ctxInvalid), sym_(sym)
#ifndef NDEBUG
    ,
    counter_(counter)
#endif
{
  assert(smellsLikeES6Symbol(ctx_, sym_));
  JSValueProtect(ctx_, sym_);
#ifndef NDEBUG
  counter_ += 1;
#endif
}

void JSCContext::JSCSymbolValue::invalidate() {
#ifndef NDEBUG
  counter_ -= 1;
#endif

  if (!ctxInvalid_) {
    JSValueUnprotect(ctx_, sym_);
  }
  delete this;
}

#ifndef NDEBUG
JSCContext::JSCStringValue::JSCStringValue(JSStringRef str, std::atomic<intptr_t> &counter)
  : str_(JSStringRetain(str)), counter_(counter) {
  // Since std::atomic returns a copy instead of a reference when calling
  // operator+= we must do this explicitly in the constructor
  counter_ += 1;
}
#else
JSCContext::JSCStringValue::JSCStringValue(JSStringRef str) : str_(JSStringRetain(str)) {}
#endif

void JSCContext::JSCStringValue::invalidate() {
  // These JSC{String,Object}Value objects are implicitly owned by the
  // {String,Object} objects, thus when a String/Object is destructed
  // the JSC{String,Object}Value should be released.
#ifndef NDEBUG
  counter_ -= 1;
#endif
  JSStringRelease(str_);
  // Angery reaccs only
  delete this;
}

JSCContext::JSCObjectValue::JSCObjectValue(JSGlobalContextRef ctx, const std::atomic<bool> &ctxInvalid, JSObjectRef obj
#ifndef NDEBUG
                                           ,
                                           std::atomic<intptr_t> &counter
#endif
                                           )
  : ctx_(ctx), ctxInvalid_(ctxInvalid), obj_(obj)
#ifndef NDEBUG
    ,
    counter_(counter)
#endif
{
  JSValueProtect(ctx_, obj_);
#ifndef NDEBUG
  counter_ += 1;
#endif
}

void JSCContext::JSCObjectValue::invalidate() {
#ifndef NDEBUG
  counter_ -= 1;
#endif
  // When shutting down the VM, if there is a HostObject which
  // contains or otherwise owns a jsa::Object, then the final GC will
  // finalize the HostObject, leading to a call to invalidate().  But
  // at that point, making calls to JSValueUnprotect will crash.
  // It is up to the application to make sure that any other calls to
  // invalidate() happen before VM destruction; see the comment on
  // jsa::JSContext.
  //
  // Another potential concern here is that in the non-shutdown case,
  // if a HostObject is GCd, JSValueUnprotect will be called from the
  // JSC finalizer.  The documentation warns against this: "You must
  // not call any function that may cause a garbage collection or an
  // allocation of a garbage collected object from within a
  // JSObjectFinalizeCallback. This includes all functions that have a
  // JSContextRef parameter." However, an audit of the source code for
  // JSValueUnprotect in late 2018 shows that it cannot cause
  // allocation or a GC, and further, this code has not changed in
  // about two years.  In the future, we may choose to reintroduce the
  // mechanism previously used here which uses a separate thread for
  // JSValueUnprotect, in order to conform to the documented API, but
  // use the "unsafe" synchronous version on iOS 11 and earlier.

  if (!ctxInvalid_) {
    JSValueUnprotect(ctx_, obj_);
  }
  delete this;
}

jsa::JSContext::PointerValue *JSCContext::cloneSymbol(const jsa::JSContext::PointerValue *pv) {
  if (!pv) {
    return nullptr;
  }
  const JSCSymbolValue *symbol = static_cast<const JSCSymbolValue *>(pv);
  return makeSymbolValue(symbol->sym_);
}

jsa::JSContext::PointerValue *JSCContext::cloneString(const jsa::JSContext::PointerValue *pv) {
  if (!pv) {
    return nullptr;
  }
  const JSCStringValue *string = static_cast<const JSCStringValue *>(pv);
  return makeStringValue(string->str_);
}

jsa::JSContext::PointerValue *JSCContext::cloneObject(const jsa::JSContext::PointerValue *pv) {
  if (!pv) {
    return nullptr;
  }
  const JSCObjectValue *object = static_cast<const JSCObjectValue *>(pv);
  assert(object->ctx_ == ctx_ && "Don't try to clone an object backed by a different JSContext");
  return makeObjectValue(object->obj_);
}

jsa::JSContext::PointerValue *JSCContext::clonePropNameID(const jsa::JSContext::PointerValue *pv) {
  if (!pv) {
    return nullptr;
  }
  const JSCStringValue *string = static_cast<const JSCStringValue *>(pv);
  return makeStringValue(string->str_);
}

jsa::PropNameID JSCContext::createPropNameIDFromAscii(const char *str, size_t length) {
  // For system JSC this must is identical to a string
  std::string tmp(str, length);
  JSStringRef strRef = JSStringCreateWithUTF8CString(tmp.c_str());
  auto res = createPropNameID(strRef);
  JSStringRelease(strRef);
  return res;
}

jsa::PropNameID JSCContext::createPropNameIDFromUtf8(const uint8_t *utf8, size_t length) {
  std::string tmp(reinterpret_cast<const char *>(utf8), length);
  JSStringRef strRef = JSStringCreateWithUTF8CString(tmp.c_str());
  auto res = createPropNameID(strRef);
  JSStringRelease(strRef);
  return res;
}

jsa::PropNameID JSCContext::createPropNameIDFromString(const jsa::String &str) {
  return createPropNameID(stringRef(str));
}

std::string JSCContext::utf8(const jsa::PropNameID &sym) {
  return JSStringToSTLString(stringRef(sym));
}

bool JSCContext::compare(const jsa::PropNameID &a, const jsa::PropNameID &b) {
  return JSStringIsEqual(stringRef(a), stringRef(b));
}

std::string JSCContext::symbolToString(const jsa::Symbol &sym) {
  return jsa::Value(*this, sym).toString(*this).utf8(*this);
}

jsa::String JSCContext::createStringFromAscii(const char *str, size_t length) {
  // Yes we end up double casting for semantic reasons (UTF8 contains ASCII,
  // not the other way around)
  return this->createStringFromUtf8(reinterpret_cast<const uint8_t *>(str), length);
}

jsa::String JSCContext::createStringFromUtf8(const uint8_t *str, size_t length) {
  std::string tmp(reinterpret_cast<const char *>(str), length);
  JSStringRef stringRef = JSStringCreateWithUTF8CString(tmp.c_str());
  return createString(stringRef);
}

std::string JSCContext::utf8(const jsa::String &str) {
  return JSStringToSTLString(stringRef(str));
}

jsa::Object JSCContext::createObject() {
  return createObject(static_cast<JSObjectRef>(nullptr));
}

// HostObject details
namespace detail {
struct HostObjectProxyBase {
  HostObjectProxyBase(JSCContext &context, const std::shared_ptr<jsa::HostObject> &sho)
    : context_(context), hostObject(sho) {}

  JSCContext &context_;
  std::shared_ptr<jsa::HostObject> hostObject;
};
} // namespace detail

namespace {
std::once_flag hostObjectClassOnceFlag;
JSClassRef hostObjectClass{};
} // namespace

// 创建一个自定义对象
// 内部会使用JSClassCreate以及JSObjectMake函数
jsa::Object JSCContext::createObject(std::shared_ptr<jsa::HostObject> ho) {
  struct HostObjectProxy : public detail::HostObjectProxyBase {
    static JSValueRef getProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propName, JSValueRef *exception) {
      auto proxy = static_cast<HostObjectProxy *>(JSObjectGetPrivate(object));
      auto &context = proxy->context_;
      jsa::PropNameID sym = context.createPropNameID(propName);
      jsa::Value ret;
      try {
        ret = proxy->hostObject->get(context, sym);
      } catch (const jsa::JSError &error) {
        *exception = context.valueRef(error.value());
        return JSValueMakeUndefined(ctx);
      } catch (const std::exception &ex) {
        auto excValue = context.global()
                          .getPropertyAsFunction(context, "Error")
                          .call(context, std::string("Exception in HostObject::get(propName:") +
                                           JSStringToSTLString(propName) + std::string("): ") + ex.what());
        *exception = context.valueRef(excValue);
        return JSValueMakeUndefined(ctx);
      } catch (...) {
        auto excValue = context.global()
                          .getPropertyAsFunction(context, "Error")
                          .call(context, std::string("Exception in HostObject::get(propName:") +
                                           JSStringToSTLString(propName) + std::string("): <unknown>"));
        *exception = context.valueRef(excValue);
        return JSValueMakeUndefined(ctx);
      }
      return context.valueRef(ret);
    }

#define JSC_UNUSED(x) (void)(x);

    static bool setProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propName, JSValueRef value,
                            JSValueRef *exception) {
      JSC_UNUSED(ctx);
      auto proxy = static_cast<HostObjectProxy *>(JSObjectGetPrivate(object));
      auto &context = proxy->context_;
      jsa::PropNameID sym = context.createPropNameID(propName);
      try {
        proxy->hostObject->set(context, sym, context.createValue(value));
      } catch (const jsa::JSError &error) {
        *exception = context.valueRef(error.value());
        return false;
      } catch (const std::exception &ex) {
        auto excValue = context.global()
                          .getPropertyAsFunction(context, "Error")
                          .call(context, std::string("Exception in HostObject::set(propName:") +
                                           JSStringToSTLString(propName) + std::string("): ") + ex.what());
        *exception = context.valueRef(excValue);
        return false;
      } catch (...) {
        auto excValue = context.global()
                          .getPropertyAsFunction(context, "Error")
                          .call(context, std::string("Exception in HostObject::set(propName:") +
                                           JSStringToSTLString(propName) + std::string("): <unknown>"));
        *exception = context.valueRef(excValue);
        return false;
      }
      return true;
    }

    // JSC does not provide means to communicate errors from this callback,
    // so the error handling strategy is very brutal - we'll just crash
    // due to noexcept.
    static void getPropertyNames(JSContextRef ctx, JSObjectRef object,
                                 JSPropertyNameAccumulatorRef propertyNames) noexcept {
      JSC_UNUSED(ctx);
      auto proxy = static_cast<HostObjectProxy *>(JSObjectGetPrivate(object));
      auto &context = proxy->context_;
      auto names = proxy->hostObject->getPropertyNames(context);
      for (auto &name : names) {
        JSPropertyNameAccumulatorAddName(propertyNames, stringRef(name));
      }
    }

#undef JSC_UNUSED

    static void finalize(JSObjectRef obj) {
      auto hostObject = static_cast<HostObjectProxy *>(JSObjectGetPrivate(obj));
      JSObjectSetPrivate(obj, nullptr);
      delete hostObject;
    }

    using HostObjectProxyBase::HostObjectProxyBase;
  };

  std::call_once(hostObjectClassOnceFlag, []() {
    JSClassDefinition hostObjectClassDef = kJSClassDefinitionEmpty;
    hostObjectClassDef.version = 0;
    hostObjectClassDef.attributes = kJSClassAttributeNoAutomaticPrototype;
    hostObjectClassDef.finalize = HostObjectProxy::finalize;
    hostObjectClassDef.getProperty = HostObjectProxy::getProperty;
    hostObjectClassDef.setProperty = HostObjectProxy::setProperty;
    hostObjectClassDef.getPropertyNames = HostObjectProxy::getPropertyNames;
    hostObjectClass = JSClassCreate(&hostObjectClassDef);
  });

  JSObjectRef obj = JSObjectMake(ctx_, hostObjectClass, new HostObjectProxy(*this, ho));
  return createObject(obj);
}

// 返回jsa::Object实际包含的HostObject
std::shared_ptr<jsa::HostObject> JSCContext::getHostObject(const jsa::Object &obj) {
  // We are guarenteed at this point to have isHostObject(obj) == true
  // so the private data should be HostObjectMetadata
  JSObjectRef object = objectRef(obj);
  auto metadata = static_cast<detail::HostObjectProxyBase *>(JSObjectGetPrivate(object));
  assert(metadata);
  return metadata->hostObject;
}

jsa::Value JSCContext::getProperty(const jsa::Object &obj, const jsa::String &name) {
  JSObjectRef objRef = objectRef(obj);
  JSValueRef exc = nullptr;
  JSValueRef res = JSObjectGetProperty(ctx_, objRef, stringRef(name), &exc);
  if (hasException(exc)) return jsa::Value::null();
  return createValue(res);
}

jsa::Value JSCContext::getProperty(const jsa::Object &obj, const jsa::PropNameID &name) {
  JSObjectRef objRef = objectRef(obj);
  JSValueRef exc = nullptr;
  JSValueRef res = JSObjectGetProperty(ctx_, objRef, stringRef(name), &exc);
  if (hasException(exc)) return jsa::Value::null();
  return createValue(res);
}

bool JSCContext::hasProperty(const jsa::Object &obj, const jsa::String &name) {
  JSObjectRef objRef = objectRef(obj);
  return JSObjectHasProperty(ctx_, objRef, stringRef(name));
}

bool JSCContext::hasProperty(const jsa::Object &obj, const jsa::PropNameID &name) {
  JSObjectRef objRef = objectRef(obj);
  return JSObjectHasProperty(ctx_, objRef, stringRef(name));
}

void JSCContext::setPropertyValue(jsa::Object &object, const jsa::PropNameID &name, const jsa::Value &value) {
  JSValueRef exc = nullptr;
  JSObjectSetProperty(ctx_, objectRef(object), stringRef(name), valueRef(value), kJSPropertyAttributeNone, &exc);
  hasException(exc);
}

void JSCContext::setPropertyValue(jsa::Object &object, const jsa::String &name, const jsa::Value &value) {
  JSValueRef exc = nullptr;
  JSObjectSetProperty(ctx_, objectRef(object), stringRef(name), valueRef(value), kJSPropertyAttributeNone, &exc);
  hasException(exc);
}

bool JSCContext::isArray(const jsa::Object &obj) const {
#if !defined(_JSC_FAST_IS_ARRAY)
  JSObjectRef global = JSContextGetGlobalObject(ctx_);
  JSStringRef arrayString = getArrayString();
  JSValueRef exc = nullptr;
  JSValueRef arrayCtorValue = JSObjectGetProperty(ctx_, global, arrayString, &exc);
  JSC_ASSERT(exc);
  JSObjectRef arrayCtor = JSValueToObject(ctx_, arrayCtorValue, &exc);
  JSC_ASSERT(exc);
  JSStringRef isArrayString = getIsArrayString();
  JSValueRef isArrayValue = JSObjectGetProperty(ctx_, arrayCtor, isArrayString, &exc);
  JSC_ASSERT(exc);
  JSObjectRef isArray = JSValueToObject(ctx_, isArrayValue, &exc);
  JSC_ASSERT(exc);
  JSValueRef arg = objectRef(obj);
  JSValueRef result = JSObjectCallAsFunction(ctx_, isArray, nullptr, 1, &arg, &exc);
  JSC_ASSERT(exc);
  return JSValueToBoolean(ctx_, result);
#else
  return JSValueIsArray(ctx_, objectRef(obj));
#endif
}

bool JSCContext::isArrayBuffer(const jsa::Object &obj) const {
  auto typedArrayType = JSValueGetTypedArrayType(ctx_, objectRef(obj), nullptr);
  return typedArrayType == kJSTypedArrayTypeArrayBuffer;
}

bool JSCContext::isArrayBufferView(const jsa::Object &obj) const {
  auto typedArrayType = JSValueGetTypedArrayType(ctx_, objectRef(obj), nullptr);
  return typedArrayType == kJSTypedArrayTypeInt8Array || typedArrayType == kJSTypedArrayTypeInt16Array ||
         typedArrayType == kJSTypedArrayTypeInt32Array || typedArrayType == kJSTypedArrayTypeUint8Array ||
         typedArrayType == kJSTypedArrayTypeUint8ClampedArray || typedArrayType == kJSTypedArrayTypeUint16Array ||
         typedArrayType == kJSTypedArrayTypeUint32Array || typedArrayType == kJSTypedArrayTypeFloat32Array ||
         typedArrayType == kJSTypedArrayTypeFloat64Array;
}

void *JSCContext::data(const jsa::ArrayBuffer &obj) {
  JSValueRef exc = nullptr;
  void *data = JSObjectGetArrayBufferBytesPtr(ctx_, objectRef(obj), &exc);
  if (hasException(exc)) return nullptr;
  return data;
}

void *JSCContext::data(const jsa::ArrayBufferView &obj) {
  JSValueRef exc = nullptr;
  void *data = JSObjectGetTypedArrayBytesPtr(ctx_, objectRef(obj), &exc);
  if (hasException(exc)) return nullptr;
  return data;
}

size_t JSCContext::size(const jsa::ArrayBuffer &obj) {
  JSValueRef exc = nullptr;
  size_t size = JSObjectGetArrayBufferByteLength(ctx_, objectRef(obj), &exc);
  if (hasException(exc)) return 0;
  return size;
}

size_t JSCContext::size(const jsa::ArrayBufferView &obj) {
  JSValueRef exc = nullptr;
  size_t size = JSObjectGetTypedArrayByteLength(ctx_, objectRef(obj), &exc);
  if (hasException(exc)) return 0;
  return size;
}

jsa::ArrayBufferViewType JSCContext::arrayBufferViewType(const jsa::ArrayBufferView &arrayBufferView) {
  JSValueRef exc = nullptr;
  auto typedArrayType = JSValueGetTypedArrayType(ctx_, objectRef(arrayBufferView), &exc);
  if (hasException(exc)) return jsa::ArrayBufferViewType::none;
  ;

  switch (typedArrayType) {
  case kJSTypedArrayTypeInt8Array:
    return jsa::ArrayBufferViewType::Int8Array;
  case kJSTypedArrayTypeInt16Array:
    return jsa::ArrayBufferViewType::Int16Array;
  case kJSTypedArrayTypeInt32Array:
    return jsa::ArrayBufferViewType::Int32Array;
  case kJSTypedArrayTypeUint8Array:
    return jsa::ArrayBufferViewType::Uint8Array;
  case kJSTypedArrayTypeUint8ClampedArray:
    return jsa::ArrayBufferViewType::Uint8ClampedArray;
  case kJSTypedArrayTypeUint16Array:
    return jsa::ArrayBufferViewType::Uint16Array;
  case kJSTypedArrayTypeUint32Array:
    return jsa::ArrayBufferViewType::Uint32Array;
  case kJSTypedArrayTypeFloat32Array:
    return jsa::ArrayBufferViewType::Float32Array;
  case kJSTypedArrayTypeFloat64Array:
    return jsa::ArrayBufferViewType::Float64Array;
  default:
    break;
  }
  return jsa::ArrayBufferViewType::none;
}

bool JSCContext::isFunction(const jsa::Object &obj) const {
  return JSObjectIsFunction(ctx_, objectRef(obj)) || JSObjectIsConstructor(ctx_, objectRef(obj));
}

bool JSCContext::isHostObject(const jsa::Object &obj) const {
  auto cls = hostObjectClass;
  return cls != nullptr && JSValueIsObjectOfClass(ctx_, objectRef(obj), cls);
}

// Very expensive
jsa::Array JSCContext::getPropertyNames(const jsa::Object &obj) {
  JSPropertyNameArrayRef names = JSObjectCopyPropertyNames(ctx_, objectRef(obj));
  size_t len = JSPropertyNameArrayGetCount(names);
  // Would be better if we could create an array with explicit elements
  auto result = createArray(len);
  for (size_t i = 0; i < len; i++) {
    JSStringRef str = JSPropertyNameArrayGetNameAtIndex(names, i);
    result.setValueAtIndex(*this, i, createString(str));
  }
  JSPropertyNameArrayRelease(names);
  return result;
}

jsa::WeakObject JSCContext::createWeakObject(const jsa::Object &obj) {
  throw std::logic_error("Not implemented");
  // JSObjectRef objRef = objectRef(obj);
  // return make<jsa::WeakObject>(makeObjectValue(objRef));
}

jsa::Value JSCContext::lockWeakObject(const jsa::WeakObject &obj) {
  // JSObjectRef objRef = objectRef(obj);
  // return jsa::Value(createObject(objRef));
  throw std::logic_error("Not implemented");
}

jsa::Array JSCContext::createArray(size_t length) {
  JSValueRef exc = nullptr;
  JSObjectRef obj = JSObjectMakeArray(ctx_, 0, nullptr, &exc);
  hasException(obj, exc);
  JSObjectSetProperty(ctx_, obj, getLengthString(), JSValueMakeNumber(ctx_, static_cast<double>(length)), 0, &exc);
  hasException(exc);
  return createObject(obj).getArray(*this);
}

struct DeallocatorContext {
  DeallocatorContext(jsa::ArrayBufferDeallocator<uint8_t> f) : deallocator(f) {}
  jsa::ArrayBufferDeallocator<uint8_t> deallocator;
};
jsa::ArrayBuffer JSCContext::createArrayBuffer(uint8_t *data, size_t length,
                                               jsa::ArrayBufferDeallocator<uint8_t> deallocator) {
  JSValueRef exc = nullptr;
  JSObjectRef arrayBuffer = JSObjectMakeArrayBufferWithBytesNoCopy(
    ctx_, data, length,
    [](void *bytes, void *deallocatorContext) {
      auto data = static_cast<uint8_t *>(bytes);
      auto context = static_cast<DeallocatorContext *>(deallocatorContext);
      context->deallocator(data);
    },
    new DeallocatorContext(deallocator), &exc);
  hasException(arrayBuffer, exc);
  return createObject(arrayBuffer).getArrayBuffer(*this);
}

size_t JSCContext::size(const jsa::Array &arr) {
  return static_cast<size_t>(getProperty(arr, createPropNameID(getLengthString())).getNumber());
}

jsa::Value JSCContext::getValueAtIndex(const jsa::Array &arr, size_t i) {
  JSValueRef exc = nullptr;
  auto res = JSObjectGetPropertyAtIndex(ctx_, objectRef(arr), (int)i, &exc);
  if (hasException(exc)) return jsa::Value::null();
  return createValue(res);
}

void JSCContext::setValueAtIndexImpl(jsa::Array &arr, size_t i, const jsa::Value &value) {
  JSValueRef exc = nullptr;
  JSObjectSetPropertyAtIndex(ctx_, objectRef(arr), (int)i, valueRef(value), &exc);
  hasException(exc);
}

namespace {
std::once_flag hostFunctionClassOnceFlag;
std::once_flag hostClassOnceFlag;
JSClassRef hostFunctionClass{nullptr};
JSClassRef hostClass{nullptr};

class HostFunctionProxy {
public:
  HostFunctionProxy(jsa::HostFunctionType hostFunction) : hostFunction_(hostFunction) {}

  jsa::HostFunctionType &getHostFunction() {
    return hostFunction_;
  }

protected:
  jsa::HostFunctionType hostFunction_;
};

class HostClassProxy {
public:
  HostClassProxy(jsa::HostClassType hostClass) : hostClass_(hostClass) {}

  jsa::HostClassType &getHostClass() {
    return hostClass_;
  }

protected:
  jsa::HostClassType hostClass_;
};
} // namespace

// JS Function Binding
jsa::Function JSCContext::createFunctionFromHostFunction(const jsa::PropNameID &name, unsigned int paramCount,
                                                         jsa::HostFunctionType func) {
  class HostFunctionMetadata : public HostFunctionProxy {
  public:
    static void initialize(JSContextRef ctx, JSObjectRef object) {
      // We need to set up the prototype chain properly here. In theory we
      // could set func.prototype.prototype = Function.prototype to get the
      // same result. Not sure which approach is better.
      HostFunctionMetadata *metadata = static_cast<HostFunctionMetadata *>(JSObjectGetPrivate(object));

      JSValueRef exc = nullptr;
      JSObjectSetProperty(ctx, object, getLengthString(), JSValueMakeNumber(ctx, metadata->argCount),
                          kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum | kJSPropertyAttributeDontDelete,
                          &exc);
      if (exc) {
        // Silently fail to set length
        exc = nullptr;
      }

      JSStringRef name = nullptr;
      std::swap(metadata->name, name);
      JSObjectSetProperty(ctx, object, getNameString(), JSValueMakeString(ctx, name),
                          kJSPropertyAttributeReadOnly | kJSPropertyAttributeDontEnum | kJSPropertyAttributeDontDelete,
                          &exc);
      JSStringRelease(name);
      if (exc) {
        // Silently fail to set name
        exc = nullptr;
      }

      JSObjectRef global = JSContextGetGlobalObject(ctx);
      JSValueRef value = JSObjectGetProperty(ctx, global, getFunctionString(), &exc);
      // If we don't have Function then something bad is going on.
      if (JSC_UNLIKELY(exc)) {
        abort();
      }
      JSObjectRef funcCtor = JSValueToObject(ctx, value, &exc);
      if (!funcCtor) {
        // We can't do anything if Function is not an object
        return;
      }
      JSValueRef funcProto = JSObjectGetPrototype(ctx, funcCtor);
      JSObjectSetPrototype(ctx, object, funcProto);
    }

    static JSValueRef makeError(JSCContext &context, const std::string &desc) {
      jsa::Value value = context.global().getPropertyAsFunction(context, "Error").call(context, desc);
      return context.valueRef(value);
    }

    // JSC会调用此方法执行先前注入的JS Function
    static JSValueRef call(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception) {
      HostFunctionMetadata *metadata = static_cast<HostFunctionMetadata *>(JSObjectGetPrivate(function));
      JSCContext &context = *(metadata->context_);
      const unsigned maxStackArgCount = 8;
      jsa::Value stackArgs[maxStackArgCount];
      std::unique_ptr<jsa::Value[]> heapArgs;
      jsa::Value *args;
      if (argumentCount > maxStackArgCount) {
        heapArgs = std::make_unique<jsa::Value[]>(argumentCount);
        for (size_t i = 0; i < argumentCount; i++) {
          heapArgs[i] = context.createValue(arguments[i]);
        }
        args = heapArgs.get();
      } else {
        for (size_t i = 0; i < argumentCount; i++) {
          stackArgs[i] = context.createValue(arguments[i]);
        }
        args = stackArgs;
      }
      JSValueRef res;
      jsa::Value thisVal(context.createObject(thisObject));
      try {
        // 执行lambda
        res = context.valueRef(metadata->hostFunction_(context, thisVal, args, argumentCount));
      } catch (const jsa::JSError &error) {
        *exception = context.valueRef(error.value());
        res = JSValueMakeUndefined(ctx);
      } catch (const std::exception &ex) {
        std::string exceptionString("Exception in HostFunction: ");
        exceptionString += ex.what();
        *exception = makeError(context, exceptionString);
        res = JSValueMakeUndefined(ctx);
      } catch (...) {
        std::string exceptionString("Exception in HostFunction: <unknown>");
        *exception = makeError(context, exceptionString);
        res = JSValueMakeUndefined(ctx);
      }
      return res;
    }

    static void finalize(JSObjectRef object) {
      HostFunctionMetadata *metadata = static_cast<HostFunctionMetadata *>(JSObjectGetPrivate(object));
      JSObjectSetPrivate(object, nullptr);
      delete metadata;
    }

    HostFunctionMetadata(JSCContext *context, jsa::HostFunctionType hf, unsigned ac, JSStringRef n)
      : HostFunctionProxy(hf), context_(context), argCount(ac), name(JSStringRetain(n)) {}

    JSCContext *context_;
    unsigned argCount;
    JSStringRef name;
  };

  std::call_once(hostFunctionClassOnceFlag, []() {
    JSClassDefinition functionClass = kJSClassDefinitionEmpty;
    functionClass.version = 0;
    functionClass.attributes = kJSClassAttributeNoAutomaticPrototype;
    functionClass.initialize = HostFunctionMetadata::initialize;
    functionClass.finalize = HostFunctionMetadata::finalize;
    functionClass.callAsFunction = HostFunctionMetadata::call;

    hostFunctionClass = JSClassCreate(&functionClass);
  });

  JSObjectRef funcRef =
    JSObjectMake(ctx_, hostFunctionClass, new HostFunctionMetadata(this, func, paramCount, stringRef(name)));
  return createObject(funcRef).getFunction(*this);
}

jsa::Function JSCContext::createClassFromHostClass(const jsa::PropNameID &name, unsigned int paramCount,
                                                   jsa::HostClassType func, const jsa::Object &prototype) {
  class HostClassMetadata : public HostClassProxy {
  public:
    static void initialize(JSContextRef ctx, JSObjectRef object) {
      // We need to set up the prototype chain properly here.
      HostClassMetadata *metadata = static_cast<HostClassMetadata *>(JSObjectGetPrivate(object));
      JSObjectSetPrototype(ctx, object, metadata->prototype_);
    }

    static JSValueRef makeError(JSCContext &context, const std::string &desc) {
      jsa::Value value = context.global().getPropertyAsFunction(context, "Error").call(context, desc);
      return context.valueRef(value);
    }

    // JSC会调用此方法执行先前注入的JS Function
    static JSObjectRef call(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                            const JSValueRef arguments[], JSValueRef *exception) {
      HostClassMetadata *metadata = static_cast<HostClassMetadata *>(JSObjectGetPrivate(constructor));
      JSCContext &context = *(metadata->context_);
      const unsigned maxStackArgCount = 8;
      jsa::Value stackArgs[maxStackArgCount];
      std::unique_ptr<jsa::Value[]> heapArgs;
      jsa::Value *args;
      if (argumentCount > maxStackArgCount) {
        heapArgs = std::make_unique<jsa::Value[]>(argumentCount);
        for (size_t i = 0; i < argumentCount; i++) {
          heapArgs[i] = context.createValue(arguments[i]);
        }
        args = heapArgs.get();
      } else {
        for (size_t i = 0; i < argumentCount; i++) {
          stackArgs[i] = context.createValue(arguments[i]);
        }
        args = stackArgs;
      }
      JSObjectRef res;
      jsa::Object constructorVal(context.createObject(constructor));
      try {
        jsa::Object returnValue = metadata->hostClass_(context, constructorVal, args, argumentCount);
        res = context.objectRef(returnValue);
      } catch (const jsa::JSError &error) {
        *exception = context.valueRef(error.value());
        res = JSObjectMake(ctx, NULL, nullptr);
      } catch (const std::exception &ex) {
        std::string exceptionString("Exception in HostClass: ");
        exceptionString += ex.what();
        *exception = makeError(context, exceptionString);
        res = JSObjectMake(ctx, NULL, nullptr);
      } catch (...) {
        std::string exceptionString("Exception in HostClass: <unknown>");
        *exception = makeError(context, exceptionString);
        res = JSObjectMake(ctx, NULL, nullptr);
      }

      return res;
    }

    static void finalize(JSObjectRef object) {
      HostClassMetadata *metadata = static_cast<HostClassMetadata *>(JSObjectGetPrivate(object));
      JSObjectSetPrivate(object, nullptr);
      delete metadata;
    }

    static bool hasInstance(JSContextRef ctx, JSObjectRef constructor, JSValueRef possibleInstance,
                            JSValueRef *exception) {
      HostClassMetadata *metadata = static_cast<HostClassMetadata *>(JSObjectGetPrivate(constructor));
      JSCContext &context = *(metadata->context_);
      if (!JSValueIsObject(ctx, possibleInstance)) {
        *exception = makeError(context, "Right-hand side of 'instanceof' is not an object");
        return false;
      }
      JSObjectRef object = JSValueToObject(ctx, possibleInstance, nullptr);
      if (!JSObjectIsFunction(ctx, object) && !JSObjectIsConstructor(ctx, object)) {
        *exception = makeError(context, "Right-hand side of 'instanceof' is not callable");
        return false;
      }

      return constructor == object;
    }

    HostClassMetadata(JSCContext *context, jsa::HostClassType classType, unsigned ac, JSStringRef n,
                      JSObjectRef prototype)
      : HostClassProxy(classType), context_(context), argCount(ac), name(JSStringRetain(n)), prototype_(prototype) {}

    JSCContext *context_;
    unsigned argCount;
    JSStringRef name;
    JSObjectRef prototype_;
  };

  std::call_once(hostClassOnceFlag, [&]() {
    JSClassDefinition functionClass = kJSClassDefinitionEmpty;
    functionClass.version = 0;
    functionClass.attributes = kJSClassAttributeNoAutomaticPrototype;
    functionClass.initialize = HostClassMetadata::initialize;
    functionClass.finalize = HostClassMetadata::finalize;
    functionClass.callAsConstructor = HostClassMetadata::call;
    functionClass.className = name.utf8(*this).c_str();
    functionClass.hasInstance = HostClassMetadata::hasInstance;
    hostClass = JSClassCreate(&functionClass);
  });

  JSObjectRef funcRef =
    JSObjectMake(ctx_, hostClass, new HostClassMetadata(this, func, paramCount, stringRef(name), objectRef(prototype)));
  return createObject(funcRef).getFunction(*this);
}

namespace detail {

// 参数转换。
// jsa::Values* -> JSValueRef*
class ArgsConverter {
public:
  ArgsConverter(JSCContext &context, const jsa::Value *args, size_t count) {
    JSValueRef *destination = inline_;
    if (count > maxStackArgs) {
      outOfLine_ = std::make_unique<JSValueRef[]>(count);
      destination = outOfLine_.get();
    }

    for (size_t i = 0; i < count; ++i) {
      destination[i] = context.valueRef(args[i]);
    }
  }

  operator JSValueRef *() {
    return outOfLine_ ? outOfLine_.get() : inline_;
  }

private:
  constexpr static unsigned maxStackArgs = 8;
  JSValueRef inline_[maxStackArgs];
  std::unique_ptr<JSValueRef[]> outOfLine_;
};
} // namespace detail

bool JSCContext::isHostFunction(const jsa::Function &obj) const {
  auto cls = hostFunctionClass;
  return cls != nullptr && JSValueIsObjectOfClass(ctx_, objectRef(obj), cls);
}

bool JSCContext::isHostClass(const jsa::Function &obj) const {
  auto cls = hostClass;
  return cls != nullptr && JSValueIsObjectOfClass(ctx_, objectRef(obj), cls);
}

jsa::HostFunctionType &JSCContext::getHostFunction(const jsa::Function &obj) {
  // We know that isHostFunction(obj) is true here, so its safe to proceed
  auto proxy = static_cast<HostFunctionProxy *>(JSObjectGetPrivate(objectRef(obj)));
  return proxy->getHostFunction();
}

jsa::HostClassType &JSCContext::getHostClass(const jsa::Function &obj) {
  auto proxy = static_cast<HostClassProxy *>(JSObjectGetPrivate(objectRef(obj)));
  return proxy->getHostClass();
}

jsa::Value JSCContext::call(const jsa::Function &f, const jsa::Value &jsThis, const jsa::Value *args, size_t count) {
  JSValueRef exc = nullptr;
  auto res =
    JSObjectCallAsFunction(ctx_, objectRef(f), jsThis.isUndefined() ? nullptr : objectRef(jsThis.getObject(*this)),
                           count, detail::ArgsConverter(*this, args, count), &exc);
  hasException(exc);
  return createValue(res);
}

jsa::Value JSCContext::callAsConstructor(const jsa::Function &f, const jsa::Value *args, size_t count) {
  JSValueRef exc = nullptr;
  auto res = JSObjectCallAsConstructor(ctx_, objectRef(f), count, detail::ArgsConverter(*this, args, count), &exc);
  hasException(exc);
  return createValue(res);
}

bool JSCContext::strictEquals(const jsa::Symbol &a, const jsa::Symbol &b) const {
  JSValueRef exc = nullptr;
  bool ret = JSValueIsEqual(ctx_, symbolRef(a), symbolRef(b), &exc);
  const_cast<JSCContext *>(this)->hasException(exc);
  return ret;
}

bool JSCContext::strictEquals(const jsa::String &a, const jsa::String &b) const {
  return JSStringIsEqual(stringRef(a), stringRef(b));
}

bool JSCContext::strictEquals(const jsa::Object &a, const jsa::Object &b) const {
  return objectRef(a) == objectRef(b);
}

bool JSCContext::instanceOf(const jsa::Object &o, const jsa::Function &f) {
  JSValueRef exc = nullptr;
  bool res = JSValueIsInstanceOfConstructor(ctx_, objectRef(o), objectRef(f), &exc);
  hasException(exc);
  return res;
}

jsa::JSContext::PointerValue *JSCContext::makeSymbolValue(JSValueRef symbolRef) const {
#ifndef NDEBUG
  return new JSCSymbolValue(ctx_, ctxInvalid_, symbolRef, symbolCounter_);
#else
  return new JSCSymbolValue(ctx_, ctxInvalid_, symbolRef);
#endif
}

namespace {
JSStringRef getEmptyString() {
  static JSStringRef empty = JSStringCreateWithUTF8CString("");
  return empty;
}
} // namespace

jsa::JSContext::PointerValue *JSCContext::makeStringValue(JSStringRef stringRef) const {
  if (!stringRef) {
    stringRef = getEmptyString();
  }
#ifndef NDEBUG
  return new JSCStringValue(stringRef, stringCounter_);
#else
  return new JSCStringValue(stringRef);
#endif
}

jsa::Symbol JSCContext::createSymbol(JSValueRef sym) const {
  return make<jsa::Symbol>(makeSymbolValue(sym));
}

jsa::String JSCContext::createString(JSStringRef str) const {
  return make<jsa::String>(makeStringValue(str));
}

jsa::PropNameID JSCContext::createPropNameID(JSStringRef str) {
  return make<jsa::PropNameID>(makeStringValue(str));
}

jsa::JSContext::PointerValue *JSCContext::makeObjectValue(JSObjectRef objectRef) const {
  if (!objectRef) {
    objectRef = JSObjectMake(ctx_, nullptr, nullptr);
  }
#ifndef NDEBUG
  return new JSCObjectValue(ctx_, ctxInvalid_, objectRef, objectCounter_);
#else
  return new JSCObjectValue(ctx_, ctxInvalid_, objectRef);
#endif
}

jsa::Object JSCContext::createObject(JSObjectRef obj) const {
  return make<jsa::Object>(makeObjectValue(obj));
}

jsa::Value JSCContext::createValue(JSValueRef value) const {
  if (JSValueIsNumber(ctx_, value)) {
    return jsa::Value(JSValueToNumber(ctx_, value, nullptr));
  } else if (JSValueIsBoolean(ctx_, value)) {
    return jsa::Value(JSValueToBoolean(ctx_, value));
  } else if (JSValueIsNull(ctx_, value)) {
    return jsa::Value(nullptr);
  } else if (JSValueIsUndefined(ctx_, value)) {
    return jsa::Value();
  } else if (JSValueIsString(ctx_, value)) {
    JSStringRef str = JSValueToStringCopy(ctx_, value, nullptr);
    auto result = jsa::Value(createString(str));
    JSStringRelease(str);
    return result;
  } else if (JSValueIsObject(ctx_, value)) {
    JSObjectRef objRef = JSValueToObject(ctx_, value, nullptr);
    return jsa::Value(createObject(objRef));
  } else if (smellsLikeES6Symbol(ctx_, value)) {
    return jsa::Value(createSymbol(value));
  } else {
    // WHAT ARE YOU
    abort();
  }
}

JSValueRef JSCContext::valueRef(const jsa::Value &value) {
  // I would rather switch on value.kind_
  if (value.isUndefined()) {
    return JSValueMakeUndefined(ctx_);
  } else if (value.isNull()) {
    return JSValueMakeNull(ctx_);
  } else if (value.isBool()) {
    return JSValueMakeBoolean(ctx_, value.getBool());
  } else if (value.isNumber()) {
    return JSValueMakeNumber(ctx_, value.getNumber());
  } else if (value.isSymbol()) {
    return symbolRef(value.getSymbol(*this));
  } else if (value.isString()) {
    return JSValueMakeString(ctx_, stringRef(value.getString(*this)));
  } else if (value.isObject()) {
    return objectRef(value.getObject(*this));
  } else {
    // What are you?
    abort();
  }
}

JSValueRef JSCContext::symbolRef(const jsa::Symbol &sym) {
  return static_cast<const JSCSymbolValue *>(getPointerValue(sym))->sym_;
}

JSStringRef JSCContext::stringRef(const jsa::String &str) {
  return static_cast<const JSCStringValue *>(getPointerValue(str))->str_;
}

JSStringRef JSCContext::stringRef(const jsa::PropNameID &sym) {
  return static_cast<const JSCStringValue *>(getPointerValue(sym))->str_;
}

JSObjectRef JSCContext::objectRef(const jsa::Object &obj) {
  return static_cast<const JSCObjectValue *>(getPointerValue(obj))->obj_;
}

bool JSCContext::hasException(JSValueRef exc) {
  if (JSC_UNLIKELY(exc)) {
    jsa::JSError error = jsa::JSError(*this, createValue(exc));
    _handler(error);
    return true;
  }
  return false;
}

bool JSCContext::hasException(JSValueRef res, JSValueRef exc) {
  if (JSC_UNLIKELY(!res)) {
    jsa::JSError error = jsa::JSError(*this, createValue(exc));
    _handler(error);
    return true;
  }
  return false;
}

bool JSCContext::hasException(JSValueRef exc, const char *msg) {
  if (JSC_UNLIKELY(exc)) {
    jsa::JSError error = jsa::JSError(std::string(msg), *this, createValue(exc));
    _handler(error);
    return true;
  }
  return false;
}

bool JSCContext::hasException(JSValueRef res, JSValueRef exc, const char *msg) {
  if (JSC_UNLIKELY(!res)) {
    jsa::JSError error = jsa::JSError(std::string(msg), *this, createValue(exc));
    _handler(error);
    return true;
  }
  return false;
}

///////////////////////////////////////////////////////////////////////////////
std::unique_ptr<jsa::JSContext> createJSContext(jsa::JSExceptionHandler handler) {
  return std::make_unique<JSCContext>(handler);
}

} // namespace jsc
} // namespace alibaba
