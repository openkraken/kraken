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
v8::Isolate *isolate {nullptr};

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
  v8::Isolate::CreateParams createParams;
  createParams.array_buffer_allocator =
      v8::ArrayBuffer::Allocator::NewDefaultAllocator();
  isolate = v8::Isolate::New(createParams);
}

jsa::Value V8Context::evaluateJavaScript(const char *code,
                                         const std::string &sourceURL,
                                         int startLine) {
  v8::Isolate::Scope isolate_scope(_isolate);
  v8::HandleScope handle_scope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
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

  return createValue(result);
}

V8Context::V8Context()
    : ctxInvalid_(false)
#ifndef NDEBUG
      ,
      objectCounter_(0), stringCounter_(0)
#endif
{
  assert(isolate != nullptr);
  _isolate = isolate;
  inst = std::make_unique<V8Instrumentation>(_isolate);

  v8::Isolate::Scope isolate_scope(_isolate);
  v8::HandleScope handle_scope(_isolate);

  v8::Local<v8::Context> context = v8::Context::New(_isolate);
  v8::Context::Scope context_scope(context);

  _context.Reset(_isolate, context);
  v8::Local<v8::Object> global = context->Global();
  v8::Local<v8::Value> globalValue = v8::Local<v8::Value>::Cast(global);
  v8::Local<v8::String> globalKey =
      v8::String::NewFromUtf8(_isolate, "global").ToLocalChecked();
  global->Set(context, globalKey, globalValue).ToChecked();
  _global.Reset(_isolate, global);
}

V8Context::~V8Context() {
  ctxInvalid_ = true;
  _context.Reset();
  _global.Reset();

#ifndef NDEBUG
  assert(objectCounter_ == 0 &&
         "V8Context destroyed with a dangling API object");
  assert(stringCounter_ == 0 &&
         "V8Context destroyed with a dangling API string");
#endif
}

jsa::Value V8Context::createValue(v8::Local<v8::Value> &value) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
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
    v8::Local<v8::String> str = v8::Local<v8::String>::New(
        _isolate, v8::Local<v8::String>::Cast(value));
    return jsa::Value(createString(str));
  } else if (value->IsStringObject()) {
    v8::Local<v8::StringObject> str = v8::Local<v8::StringObject>::Cast(value);
    v8::String::Utf8Value utf8Value(_isolate, str);
    return jsa::Value(
        this->createStringFromAscii(*utf8Value, strlen(*utf8Value)));
  } else if (value->IsSymbol() || value->IsSymbolObject()) {
    v8::Local<v8::Symbol> sym = v8::Local<v8::Symbol>::Cast(value);
    return jsa::Value(createSymbol(sym));
  } else if (value->IsObject()) {
    v8::Local<v8::Object> object = v8::Local<v8::Object>::Cast(value);
    return jsa::Value(createObject(object));
  } else {
    v8::Local<v8::Value> result;
    bool success = value->ToString(context).ToLocal(&result);
    if (success) {
      v8::String::Utf8Value utf8Value(_isolate, result);
      fprintf(stderr, "unknown V8 value kind, val: %s \n",
              ToCString(utf8Value));
    } else {
      fprintf(stderr, "unknown V8 value kind");
    }

    abort();
  }
}

v8::Local<v8::Value> V8Context::valueRef(const jsa::Value &value) {
  v8::EscapableHandleScope handleScope(_isolate);
  // I would rather switch on value.kind_
  if (value.isUndefined()) {
    return handleScope.Escape(v8::Undefined(_isolate));
  } else if (value.isNull()) {
    return handleScope.Escape(v8::Null(_isolate));
  } else if (value.isBool()) {
    return handleScope.Escape(v8::Boolean::New(_isolate, value.getBool()));
  } else if (value.isNumber()) {
    return handleScope.Escape(v8::Number::New(_isolate, value.getNumber()));
  } else if (value.isSymbol()) {
    return handleScope.Escape(symbolRef(value.getSymbol(*this)));
  } else if (value.isString()) {
    return handleScope.Escape(
        v8::String::NewFromUtf8(_isolate,
                                value.getString(*this).utf8(*this).c_str())
            .ToLocalChecked());
  } else if (value.isObject()) {
    return handleScope.Escape(v8::Local<v8::Object>::New(
        _isolate, objectRef(value.getObject(*this))));
  } else {
    // What are you?
    abort();
  }
}

jsa::Object V8Context::global() {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Object> global = _global.Get(_isolate);
  return createObject(global);
}

std::string V8Context::description() { return std::string(""); }

bool V8Context::isInspectable() { return false; }

void *V8Context::globalImpl() {}

void V8Context::setDescription(const std::string &desc) {
}

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
                                        v8::Local<v8::String> string)
    : isolate_(isolate) {
  str_.Reset(isolate, string);
}
#endif

void V8Context::V8StringValue::invalidate() {
#ifndef NDEBUG
  counter_ -= 1;
#endif
  str_.Reset();
  delete this;
}

V8Context::V8SymbolValue::V8SymbolValue(v8::Isolate *isolate,
                                        const std::atomic<bool> &ctxInvalid,
                                        v8::Local<v8::Symbol> sym
#ifndef NDEBUG
                                        ,
                                        std::atomic<intptr_t> &counter
#endif
                                        )
    : ctxInvalid_(ctxInvalid), isolate_(isolate)
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

V8Context::V8ObjectValue::V8ObjectValue(v8::Isolate *isolate,
                                        const std::atomic<bool> &ctxInvalid,
                                        v8::Local<v8::Object> &obj
#ifndef NDEBUG
                                        ,
                                        std::atomic<intptr_t> &counter
#endif
                                        )
    : ctxInvalid_(ctxInvalid), isolate_(isolate)
#ifndef NDEBUG
      ,
      counter_(counter)
#endif
{
#ifndef NDEBUG
  counter_ += 1;
#endif
  obj_.Reset(isolate, obj);
}

void V8Context::V8ObjectValue::invalidate() {
#ifndef NDEBUG
  counter_ -= 1;
#endif
  obj_.Reset();
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
  if (!pv) {
    return nullptr;
  }
  v8::HandleScope handleScope(_isolate);
  const auto *pointer = static_cast<const V8ObjectValue *>(pv);
  v8::Local<v8::Object> obj = pointer->obj_.Get(_isolate);
  return makeObjectValue(obj);
}

jsa::JSContext::PointerValue *
V8Context::clonePropNameID(const jsa::JSContext::PointerValue *pv) {
  if (!pv) {
    return nullptr;
  }
  const auto *string = static_cast<const V8StringValue *>(pv);
  return makeStringValue(string->str_.Get(_isolate));
}

jsa::PropNameID V8Context::createPropNameIDFromAscii(const char *str,
                                                     size_t length) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::String> value =
      v8::String::NewFromUtf8(_isolate, str).ToLocalChecked();
  return createPropNameID(value);
}

jsa::PropNameID V8Context::createPropNameIDFromUtf8(const uint8_t *utf8,
                                                    size_t length) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::String> value =
      v8::String::NewFromOneByte(_isolate, utf8).ToLocalChecked();
  return createPropNameID(value);
}

jsa::PropNameID V8Context::createPropNameIDFromString(const jsa::String &str) {
  v8::HandleScope handleScope(_isolate);
  std::string source = str.utf8(*this);
  v8::Local<v8::String> value =
      v8::String::NewFromUtf8(_isolate, source.c_str()).ToLocalChecked();
  return createPropNameID(value);
}

std::string V8Context::utf8(const jsa::PropNameID &propNameId) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::String> value = stringRef(propNameId);
  v8::String::Utf8Value utf8Value(_isolate, value);
  return std::string(*utf8Value);
}

bool V8Context::compare(const jsa::PropNameID &left,
                        const jsa::PropNameID &right) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::String> leftString = stringRef(left);
  v8::Local<v8::String> rightString = stringRef(right);
  return leftString->Equals(context, rightString).ToChecked();
}

std::string V8Context::symbolToString(const jsa::Symbol &sym) {
  return jsa::Value(*this, sym).toString(*this).utf8(*this);
}

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

jsa::Object V8Context::createObject() {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::Object> newObject = v8::Object::New(_isolate);
  return createObject(newObject);
}

jsa::Object V8Context::createObject(std::shared_ptr<jsa::HostObject> ho) {
  // TODO createObject
}

std::shared_ptr<jsa::HostObject> V8Context::getHostObject(const jsa::Object &) {
  // TODO getHostObject
}

jsa::HostFunctionType &V8Context::getHostFunction(const jsa::Function &) {
  // TODO getHostFunction
}

jsa::Value V8Context::getProperty(const jsa::Object &obj,
                                  const jsa::String &name) {
  assert(hasProperty(obj, name));
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  auto pointer = static_cast<const V8ObjectValue *>(getPointerValue(obj));
  v8::Local<v8::Object> object = pointer->obj_.Get(pointer->isolate_);
  std::string cKey = name.utf8(*this);
  v8::Local<v8::String> key =
      v8::String::NewFromUtf8(_isolate, name.utf8(*this).c_str())
          .ToLocalChecked();
  v8::Local<v8::Value> result = object->Get(context, key).ToLocalChecked();
  return createValue(result);
}

jsa::Value V8Context::getProperty(const jsa::Object &obj,
                                  const jsa::PropNameID &name) {
  assert(hasProperty(obj, name));
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);

  v8::Local<v8::Object> object = objectRef(obj);
  v8::Local<v8::String> key =
      v8::String::NewFromUtf8(_isolate, name.utf8(*this).c_str())
          .ToLocalChecked();
  v8::Local<v8::Value> result = object->Get(context, key).ToLocalChecked();
  return createValue(result);
}

bool V8Context::hasProperty(const jsa::Object &obj, const jsa::String &name) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::Object> object = objectRef(obj);
  v8::Local<v8::String> key =
      v8::String::NewFromUtf8(_isolate, name.utf8(*this).c_str())
          .ToLocalChecked();
  return object->Has(context, key).ToChecked();
}

bool V8Context::hasProperty(const jsa::Object &obj,
                            const jsa::PropNameID &name) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::Object> object = objectRef(obj);
  v8::Local<v8::String> key =
      v8::String::NewFromUtf8(_isolate, name.utf8(*this).c_str())
          .ToLocalChecked();
  return object->Has(context, key).ToChecked();
}

void V8Context::setPropertyValue(jsa::Object &obj, const jsa::String &name,
                                 const jsa::Value &val) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::Object> object = objectRef(obj);
  v8::Local<v8::String> key =
      v8::String::NewFromUtf8(object->GetIsolate(), name.utf8(*this).c_str())
          .ToLocalChecked();
  v8::Local<v8::Value> value = valueRef(val);
  object->Set(context, key, value).ToChecked();
}

void V8Context::setPropertyValue(jsa::Object &obj, const jsa::PropNameID &name,
                                 const jsa::Value &val) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::Object> object =
      v8::Local<v8::Object>::New(_isolate, objectRef(obj));
  v8::Local<v8::String> key =
      v8::String::NewFromUtf8(_isolate, name.utf8(*this).c_str())
          .ToLocalChecked();
  v8::Local<v8::Value> value = valueRef(val);
  object->Set(context, key, value).ToChecked();
}

bool V8Context::isArray(const jsa::Object &obj) const {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Object> object = objectRef(obj);
  return object->IsArray();
}

bool V8Context::isArrayBuffer(const jsa::Object &obj) const {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Object> object =
      v8::Local<v8::Object>::New(_isolate, objectRef(obj));
  return object->IsArrayBuffer();
}

bool V8Context::isFunction(const jsa::Object &obj) const {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Object> object =
      v8::Local<v8::Object>::New(_isolate, objectRef(obj));
  return object->IsFunction();
}

bool V8Context::isHostObject(const jsa::Object &) const {
  // TODO isHostObject
}

bool V8Context::isHostFunction(const jsa::Function &) const {
  // TODO isHostFunction
}

jsa::Array V8Context::getPropertyNames(const jsa::Object &obj) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::Object> object =
      v8::Local<v8::Object>::New(_isolate, objectRef(obj));
  v8::Local<v8::Array> names =
      object->GetPropertyNames(context).ToLocalChecked();
  auto result = createArray(names->Length());
}

jsa::WeakObject V8Context::createWeakObject(const jsa::Object &) {
  // TODO createWeakObject
}

jsa::Value V8Context::lockWeakObject(const jsa::WeakObject &) {
  // TODO LockWeakObject
}

jsa::Array V8Context::createArray(size_t length) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Array> arr = v8::Array::New(_isolate, length);
  v8::Local<v8::Object> object = v8::Local<v8::Object>::Cast(arr);
  return createObject(object).getArray(*this);
}

size_t V8Context::size(const jsa::Array &arr) {
  assert(isArray(arr));
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Object> obj = objectRef(arr);
  return v8::Local<v8::Array>::Cast(obj)->Length();
}
size_t V8Context::size(const jsa::ArrayBuffer &arrayBuffer) {
  assert(isArrayBuffer(arrayBuffer));
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Object> obj = objectRef(arrayBuffer);
  return v8::Local<v8::ArrayBuffer>::Cast(obj)->ByteLength();
}
void *V8Context::data(const jsa::ArrayBuffer &arrayBuffer) {
  assert(isArrayBuffer(arrayBuffer));
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Object> obj = objectRef(arrayBuffer);
  v8::Local<v8::ArrayBuffer> buffer = v8::Local<v8::ArrayBuffer>::Cast(obj);
  return buffer->GetContents().Data();
}
jsa::Value V8Context::getValueAtIndex(const jsa::Array &arr, size_t i) {
  assert(isArray(arr));
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::Object> obj = objectRef(arr);
  v8::Local<v8::Array> array = v8::Local<v8::Array>::Cast(obj);
  v8::Local<v8::Value> result = array->Get(context, i).ToLocalChecked();
  return createValue(result);
}

void V8Context::setValueAtIndexImpl(jsa::Array &arr, size_t i,
                                    const jsa::Value &value) {
  assert(isArray(arr));
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::Object> obj = objectRef(arr);
  v8::Local<v8::Array> array = v8::Local<v8::Array>::Cast(obj);
  bool success = array->Set(context, i, valueRef(value)).ToChecked();
  assert(success);
}
jsa::Function
V8Context::createFunctionFromHostFunction(const jsa::PropNameID &name,
                                          unsigned int paramCount,
                                          jsa::HostFunctionType func) {
// TODO CreateFunctionFromHostFunction
}
jsa::Value V8Context::call(const jsa::Function &function,
                           const jsa::Value &jsThis, const jsa::Value *args,
                           size_t count) {
  // TODO call
}

jsa::Value V8Context::callAsConstructor(const jsa::Function &,
                                        const jsa::Value *args, size_t count) {
  // TODO callAsConstructor
  return jsa::Value();
}
bool V8Context::strictEquals(const jsa::Symbol &a, const jsa::Symbol &b) const {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Symbol> leftSymbol = symbolRef(a);
  v8::Local<v8::Symbol> rightSymbol = symbolRef(b);
  return leftSymbol->StrictEquals(rightSymbol);
}
bool V8Context::strictEquals(const jsa::String &a, const jsa::String &b) const {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::String> left = stringRef(a);
  v8::Local<v8::String> right = stringRef(b);
  return left->StrictEquals(right);
}
bool V8Context::strictEquals(const jsa::Object &a, const jsa::Object &b) const {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Object> left = objectRef(a);
  v8::Local<v8::Object> right = objectRef(b);
  return left->StrictEquals(right);
}

bool V8Context::instanceOf(const jsa::Object &o, const jsa::Function &f) {
  v8::HandleScope handleScope(_isolate);
  v8::Local<v8::Context> context = _context.Get(_isolate);
  v8::Context::Scope contextScope(context);
  v8::Local<v8::Object> obj = objectRef(o);
  v8::Local<v8::Object> func = objectRef(f);
  return obj->InstanceOf(context, func).ToChecked();
}

v8::Local<v8::Symbol> V8Context::symbolRef(const jsa::Symbol &sym) const {
  v8::EscapableHandleScope handleScope(_isolate);
  auto pointer = static_cast<const V8SymbolValue *>(getPointerValue(sym));
  return handleScope.Escape(pointer->sym_.Get(pointer->isolate_));
}

v8::Local<v8::String> V8Context::stringRef(const jsa::String &str) const {
  v8::EscapableHandleScope handleScope(_isolate);
  auto pointer = static_cast<const V8StringValue *>(getPointerValue(str));
  return handleScope.Escape(pointer->str_.Get(pointer->isolate_));
}

v8::Local<v8::String>
V8Context::stringRef(const jsa::PropNameID &propNameId) const {
  v8::EscapableHandleScope handleScope(_isolate);
  auto pointer =
      static_cast<const V8StringValue *>(getPointerValue(propNameId));
  return handleScope.Escape(pointer->str_.Get(pointer->isolate_));
}

v8::Local<v8::Object> V8Context::objectRef(const jsa::Object &obj) const {
  v8::EscapableHandleScope handleScope(_isolate);
  auto pointer = static_cast<const V8ObjectValue *>(getPointerValue(obj));
  return handleScope.Escape(pointer->obj_.Get(pointer->isolate_));
}

jsa::Symbol V8Context::createSymbol(v8::Local<v8::Symbol> symbol) const {
  return make<jsa::Symbol>(makeSymbolValue(symbol));
}

jsa::String V8Context::createString(v8::Local<v8::String> value) const {
  return make<jsa::String>(makeStringValue(value));
}

jsa::PropNameID V8Context::createPropNameID(v8::Local<v8::String> string) {
  return make<jsa::PropNameID>(makeStringValue(string));
}

jsa::Object V8Context::createObject(v8::Local<v8::Object> &object) const {
  return make<jsa::Object>(makeObjectValue(object));
}

jsa::JSContext::PointerValue *
V8Context::makeSymbolValue(v8::Local<v8::Symbol> sym) const {
#ifndef NDEBUG
  return new V8SymbolValue(_isolate, ctxInvalid_, sym, symbolCounter_);
#else
  return new V8SymbolValue(_isolate, ctxInvalid_, sym);
#endif
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
V8Context::makeObjectValue(v8::Local<v8::Object> &obj) const {
  v8::HandleScope handleScope(_isolate);
#ifndef NDEBUG
  return new V8ObjectValue(_isolate, ctxInvalid_, obj, objectCounter_);
#else
  return new V8ObjectValue(_isolate, ctxInvalid_, obj);
#endif
}

V8Instrumentation &V8Context::instrumentation() { return *inst; }

std::unique_ptr<jsa::JSContext> createJSContext() {
  return std::make_unique<V8Context>();
}

} // namespace jsa_v8
} // namespace alibaba
