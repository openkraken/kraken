/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "v8_implementation.h"
#include <iostream>
#include <memory>
#include <string>

namespace alibaba {
namespace jsa_v8 {

using namespace alibaba;

namespace {
std::atomic<bool> v8_inited{false};
std::unique_ptr<v8::Platform> platform;

v8::Local<v8::String> getEmptyString(v8::Isolate *isolate) {
  static v8::Local<v8::String> empty =
      v8::String::NewFromUtf8(isolate, "").ToLocalChecked();
  return empty;
}

const char *ToCString(const v8::String::Utf8Value &value) {
  return *value ? *value : "<string conversion failed>";
}

void reportException(v8::Isolate *isolate, v8::TryCatch &tryCatch) {
  v8::HandleScope handleScope(isolate);
  v8::String::Utf8Value exception(isolate, tryCatch.Exception());
  const char *exception_string = ToCString(exception);
  v8::Local<v8::Message> message = tryCatch.Message();
  if (message.IsEmpty()) {
    fprintf(stderr, "%s\n", exception_string);
  } else {
    v8::String::Utf8Value filename(isolate,
                                   message->GetScriptOrigin().ResourceName());
    v8::Local<v8::Context> context(isolate->GetCurrentContext());
    const char *filename_string = ToCString(filename);
    int linenum = message->GetLineNumber(context).FromJust();
    fprintf(stderr, "%s:%i: %s\n", filename_string, linenum, exception_string);

    v8::String::Utf8Value sourceline(
        isolate, message->GetSourceLine(context).ToLocalChecked());
    const char *sourceline_string = ToCString(sourceline);
    fprintf(stderr, "%s\n", sourceline_string);

    int start = message->GetStartColumn(context).FromJust();
    for (int i = 0; i < start; i++) {
      fprintf(stderr, " ");
    }
    int end = message->GetEndColumn(context).FromJust();
    for (int i = start; i < end; i++) {
      fprintf(stderr, "^");
    }
    fprintf(stderr, "\n");
    v8::Local<v8::Value> stack_trace_string;
    if (tryCatch.StackTrace(context).ToLocal(&stack_trace_string) &&
        stack_trace_string->IsString() &&
        v8::Local<v8::String>::Cast(stack_trace_string)->Length() > 0) {
      v8::String::Utf8Value stack_trace(isolate, stack_trace_string);
      const char *stack_trace_string = ToCString(stack_trace);
      fprintf(stderr, "%s\n", stack_trace_string);
    }
  }
};

} // namespace

void initV8Engine(const char *current_directory) {
  if (v8_inited == true) {
    return;
  }
  v8_inited = true;
  v8::V8::InitializeICUDefaultLocation(current_directory);
  v8::V8::InitializeExternalStartupData(current_directory);
  platform = v8::platform::NewDefaultPlatform();
  v8::V8::InitializePlatform(platform.get());
  v8::V8::Initialize();
}

jsa::Value V8Context::evaluateJavaScript(const char *code,
                                         const std::string &sourceURL,
                                         int startLine) {
  v8::Isolate::Scope isolate_scope(_isolate);
  v8::HandleScope handle_scope(_isolate);
  v8::Local<v8::Context> context = v8::Context::New(_isolate);
  v8::Context::Scope context_scope(context);

  v8::TryCatch tryCatch(_isolate);

  v8::Local<v8::String> sourceCode =
      v8::String::NewFromUtf8(_isolate, code, v8::NewStringType::kNormal)
          .ToLocalChecked();
  v8::Local<v8::String> sourceURLCode =
      v8::String::NewFromUtf8(_isolate, sourceURL.c_str(),
                              v8::NewStringType::kNormal)
          .ToLocalChecked();
  v8::Local<v8::Script> script;
  v8::ScriptOrigin origin(sourceURLCode);

  if (!v8::Script::Compile(context, sourceCode, &origin).ToLocal(&script)) {
    reportException(_isolate, tryCatch);
    return jsa::Value::undefined();
  }

  v8::Local<v8::Value> result;
  if (!script->Run(context).ToLocal(&result)) {
    assert(tryCatch.HasCaught());
    reportException(_isolate, tryCatch);
    return jsa::Value::undefined();
  }

  return createValue(result, context);
}

V8Context::V8Context()
    : ctxInvalid_(false)
#ifndef NDEBUG
      ,
      objectCounter_(0), stringCounter_(0)
#endif
{
  v8::Isolate::CreateParams createParams;
  createParams.array_buffer_allocator =
      v8::ArrayBuffer::Allocator::NewDefaultAllocator();
  _isolate = v8::Isolate::New(createParams);
  inst = std::make_unique<V8Instrumentation>(_isolate);
}

V8Context::~V8Context() {
  ctxInvalid_ = true;
  // only dispose isolate
  _isolate->Dispose();

#ifndef NDEBUG
  assert(objectCounter_ == 0 &&
         "V8Context destroyed with a dangling API object");
  assert(stringCounter_ == 0 &&
         "V8Context destroyed with a dangling API string");
#endif
}

jsa::Value V8Context::createValue(v8::Local<v8::Value> value,
                                  v8::Local<v8::Context> context) {
  v8::HandleScope handleScope(_isolate);
  if (value->IsUndefined()) {
    return jsa::Value::undefined();
  } else if (value->IsNull()) {
    return jsa::Value(nullptr);
  } else if (value->IsNumber() || value->IsNumberObject()) {
    int32_t result = value.As<v8::Number>()->Int32Value(context).FromJust();
    return jsa::Value(result);
  } else if (value->IsBoolean() || value->IsBooleanObject()) {
    bool result = value.As<v8::Boolean>()->BooleanValue(_isolate);
    return jsa::Value(result);
  } else if (value->IsString()) {
    v8::Local<v8::String> str = v8::Local<v8::String>::New(_isolate, v8::Local<v8::String>::Cast(value));
    return jsa::Value(createString(str));
  } else if (value->IsStringObject()) {
    v8::Local<v8::StringObject> str = v8::Local<v8::StringObject>::Cast(value);
    v8::String::Utf8Value utf8Value(_isolate, str);
    return jsa::Value(this->createStringFromAscii(*utf8Value, strlen(*utf8Value)));
  } else if (value->IsSymbol() || value->IsSymbolObject()) {
    v8::Local<v8::Symbol> sym = v8::Local<v8::Symbol>::Cast(value);
    return jsa::Value(createSymbol(sym));
  }
  // TODO create
  return jsa::Value::undefined();
}

v8::Local<v8::Value> V8Context::valueRef(const jsa::Value &value) {
  v8::HandleScope handleScope(_isolate);
  // I would rather switch on value.kind_
  if (value.isUndefined()) {
    return v8::Undefined(_isolate);
  } else if (value.isNull()) {
    return v8::Null(_isolate);
  } else if (value.isBool()) {
    return v8::Boolean::New(_isolate, value.getBool());
  } else if (value.isNumber()) {
    return v8::Number::New(_isolate, value.getNumber());
  } else if (value.isSymbol()) {
    return symbolRef(value.getSymbol(*this));
  } else if (value.isString()) {
    return v8::String::NewFromUtf8(_isolate,
                                   value.getString(*this).utf8(*this).c_str())
        .ToLocalChecked();
  } else if (value.isObject()) {
    //    return objectRef(value.getObject(*this));
  } else {
    // What are you?
    abort();
  }
}

jsa::Object V8Context::global() {
  v8::EscapableHandleScope handleScope(_isolate);
  v8::Local<v8::ObjectTemplate> global = v8::ObjectTemplate::New(_isolate);
}

std::string V8Context::description() { return std::string(""); }

bool V8Context::isInspectable() { return false; }

void *V8Context::globalImpl() {}

void V8Context::setDescription(const std::string &desc) {}

#ifndef NDEBUG
V8Context::V8StringValue::V8StringValue(v8::Isolate *isolate,
                                        v8::Local<v8::String> string,
                                        std::atomic<intptr_t> &counter)
    : counter_(counter), isolate_(isolate) {
  // Since std::atomic returns a copy instead of a reference when calling
  // operator+= we must do this explicitly in the constructor
  counter_ += 1;
  str_.Reset(isolate, string);
}
#else
V8Context::V8StringValue::V8StringValue(v8::Isolate *isolate,
                                        v8::Local<v8::String> &str) {
  str_.Reset(isolate, str);
}
#endif

void V8Context::V8StringValue::invalidate() {
#ifndef NDEBUG
  counter_ -= 1;
#endif
  str_.Reset();
  delete this;
}

V8Context::V8SymbolValue::V8SymbolValue(
    v8::Isolate *isolate,
    const std::atomic<bool>& ctxInvalid,
    v8::Local<v8::Symbol> sym
#ifndef NDEBUG
    ,
    std::atomic<intptr_t>& counter
#endif
)
    : ctxInvalid_(ctxInvalid),
      isolate_(isolate)
#ifndef NDEBUG
    ,
      counter_(counter)
#endif
{
#ifndef NDEBUG
  counter_ += 1;
#endif
  sym_.Reset(isolate, sym);
}

void V8Context::V8SymbolValue::invalidate() {
#ifndef NDEBUG
  counter_ -= 1;
#endif

  if (!ctxInvalid_) {
    sym_.Reset();
  }
  delete this;
}


jsa::JSContext::PointerValue *
V8Context::cloneString(const jsa::JSContext::PointerValue *pv) {
  if (!pv) {
    return nullptr;
  }
  v8::HandleScope handleScope(_isolate);
  const auto *string = static_cast<const V8StringValue *>(pv);
  return makeStringValue(string->str_.Get(_isolate));
}

jsa::JSContext::PointerValue *
V8Context::cloneSymbol(const jsa::JSContext::PointerValue *pv) {
  if (!pv) {
    return nullptr;
  }
  v8::HandleScope handleScope(_isolate);
  const auto *symbol = static_cast<const V8SymbolValue *>(pv);
  return makeSymbolValue(symbol->sym_.Get(_isolate));
}

jsa::JSContext::PointerValue *
V8Context::cloneObject(const jsa::JSContext::PointerValue *pv) {
  return nullptr;
}

jsa::JSContext::PointerValue *
V8Context::clonePropNameID(const jsa::JSContext::PointerValue *pv) {
  return nullptr;
}

jsa::PropNameID V8Context::createPropNameIDFromAscii(const char *str,
                                                     size_t length) {}

jsa::PropNameID V8Context::createPropNameIDFromUtf8(const uint8_t *utf8,
                                                    size_t length) {}

jsa::PropNameID V8Context::createPropNameIDFromString(const jsa::String &str) {}

std::string V8Context::utf8(const jsa::PropNameID &) {}

bool V8Context::compare(const jsa::PropNameID &, const jsa::PropNameID &) {}

std::string V8Context::symbolToString(const jsa::Symbol &) {}

jsa::String V8Context::createStringFromAscii(const char *str, size_t length) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::String> ref =
      v8::String::NewFromUtf8(_isolate, str, v8::NewStringType::kNormal, length)
          .ToLocalChecked();
  return createString(ref);
}

jsa::String V8Context::createStringFromUtf8(const uint8_t *str, size_t length) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::String> ref =
      v8::String::NewFromOneByte(_isolate, str, v8::NewStringType::kNormal,
                                 length)
          .ToLocalChecked();
  return createString(ref);
}

std::string V8Context::utf8(const jsa::String &str) {
  v8::HandleScope handleScope(_isolate);
  v8::String::Utf8Value utf8Value(_isolate, stringRef(str));
  return std::string(*utf8Value);
}

jsa::Object V8Context::createObject() {}

jsa::Object V8Context::createObject(std::shared_ptr<jsa::HostObject> ho) {}

std::shared_ptr<jsa::HostObject> V8Context::getHostObject(const jsa::Object &) {

}

jsa::HostFunctionType &V8Context::getHostFunction(const jsa::Function &) {}

jsa::Value V8Context::getProperty(const jsa::Object &,
                                  const jsa::String &name) {}

jsa::Value V8Context::getProperty(const jsa::Object &,
                                  const jsa::PropNameID &name) {}

bool V8Context::hasProperty(const jsa::Object &, const jsa::String &name) {}

bool V8Context::hasProperty(const jsa::Object &, const jsa::PropNameID &name) {}

void V8Context::setPropertyValue(jsa::Object &, const jsa::String &name,
                                 const jsa::Value &value) {}

void V8Context::setPropertyValue(jsa::Object &, const jsa::PropNameID &name,
                                 const jsa::Value &value) {}

bool V8Context::isArray(const jsa::Object &) const {}

bool V8Context::isArrayBuffer(const jsa::Object &) const {}

bool V8Context::isFunction(const jsa::Object &) const {}

bool V8Context::isHostObject(const jsa::Object &) const {}

bool V8Context::isHostFunction(const jsa::Function &) const {}

jsa::Array V8Context::getPropertyNames(const jsa::Object &) {}

jsa::WeakObject V8Context::createWeakObject(const jsa::Object &) {}

jsa::Value V8Context::lockWeakObject(const jsa::WeakObject &) {}

jsa::Array V8Context::createArray(size_t length) {}

size_t V8Context::size(const jsa::Array &) { return 0; }
size_t V8Context::size(const jsa::ArrayBuffer &) { return 0; }
uint8_t *V8Context::data(const jsa::ArrayBuffer &) { return nullptr; }
jsa::Value V8Context::getValueAtIndex(const jsa::Array &, size_t i) {
  return jsa::Value();
}

void V8Context::setValueAtIndexImpl(jsa::Array &, size_t i,
                                    const jsa::Value &value) {}
jsa::Function
V8Context::createFunctionFromHostFunction(const jsa::PropNameID &name,
                                          unsigned int paramCount,
                                          jsa::HostFunctionType func) {}
jsa::Value V8Context::call(const jsa::Function &, const jsa::Value &jsThis,
                           const jsa::Value *args, size_t count) {
  return jsa::Value();
}

jsa::Value V8Context::callAsConstructor(const jsa::Function &,
                                        const jsa::Value *args, size_t count) {
  return jsa::Value();
}
bool V8Context::strictEquals(const jsa::Symbol &a, const jsa::Symbol &b) const {
  return false;
}
bool V8Context::strictEquals(const jsa::String &a, const jsa::String &b) const {
  return false;
}
bool V8Context::strictEquals(const jsa::Object &a, const jsa::Object &b) const {
  return false;
}
bool V8Context::instanceOf(const jsa::Object &o, const jsa::Function &f) {
  return false;
}

v8::Local<v8::Symbol> V8Context::symbolRef(const jsa::Symbol &sym) {
  auto pointer = static_cast<const V8SymbolValue *>(getPointerValue(sym));
  return pointer->sym_.Get(pointer->isolate_);
}

v8::Local<v8::String> V8Context::stringRef(const jsa::String &str) {
  auto pointer = static_cast<const V8StringValue *>(getPointerValue(str));
  return pointer->str_.Get(pointer->isolate_);
}
v8::Local<v8::String> V8Context::stringRef(const jsa::PropNameID &sym) {}
v8::Local<v8::Object> V8Context::objectRef(const jsa::Object &obj) {}

jsa::Symbol V8Context::createSymbol(v8::Local<v8::Symbol> symbol) const {
  return make<jsa::Symbol>(makeSymbolValue(symbol));
}

jsa::String V8Context::createString(v8::Local<v8::String> value) const {
  return make<jsa::String>(makeStringValue(value));
}

jsa::PropNameID V8Context::createPropNameID(v8::Local<v8::String> &string) {}

jsa::Object V8Context::createObject(v8::Local<v8::Object> object) const {}

jsa::JSContext::PointerValue *
V8Context::makeSymbolValue(v8::Local<v8::Symbol> sym) const {
  return new V8SymbolValue(_isolate, ctxInvalid_, sym, symbolCounter_);
}

jsa::JSContext::PointerValue *
V8Context::makeStringValue(v8::Local<v8::String> ref) const {
  if (ref.IsEmpty()) {
    ref = getEmptyString(_isolate);
  }

#ifndef NDEBUG
  return new V8StringValue(_isolate, ref, stringCounter_);
#else
  return new V8StringValue(_isolate, ref);
#endif
}

jsa::JSContext::PointerValue *
V8Context::makeObjectValue(v8::Local<v8::Object> &obj) const {}

V8Instrumentation &V8Context::instrumentation() { return *inst; }

std::unique_ptr<jsa::JSContext> createJSContext() {
  return std::make_unique<V8Context>();
}

} // namespace jsa_v8
} // namespace alibaba
