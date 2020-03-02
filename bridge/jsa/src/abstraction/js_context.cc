/*
* Copyright (C) 2019 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#include "js_context.h"
#include "js_error.h"
#include "js_type.h"
#include <cstdlib>
#include <instrumentation.h>

namespace alibaba {
namespace jsa {

////////////////////HostObject Definition////////////////////
Value HostObject::get(JSContext &, const PropNameID &) { return Value(); }

void HostObject::set(JSContext &context, const PropNameID &name, const Value &) {
  std::string msg("TypeError: Cannot assign to property '");
  msg += name.utf8(context);
  msg += "' on HostObject with default setter";
  throw JSError(context, msg);
}

HostObject::~HostObject() {}

std::vector<PropNameID> HostObject::getPropertyNames(JSContext &) { return {}; }

////////////////////JSRuntime Definition////////////////////
JSContext::~JSContext() {}
Instrumentation &JSContext::instrumentation() {
  class NoInstrumentation : public Instrumentation {
    std::string getRecordedGCStats() override { return ""; }

    Value getHeapInfo(bool) override { return Value::undefined(); }

    void collectGarbage() override {}

    bool createSnapshotToFile(const std::string &, bool) override {
      return false;
    }

    bool createSnapshotToStream(std::ostream &, bool) override { return false; }

    void writeBridgeTrafficTraceToFile(const std::string &) const override {
      std::abort();
    }

    void writeBasicBlockProfileTraceToFile(const std::string &) const override {
      std::abort();
    }

    void dumpProfilerSymbolsToFile(const std::string &) const override {
      std::abort();
    }
  };

  static NoInstrumentation sharedInstance;
  return sharedInstance;
}

JSContext::ScopeState *JSContext::pushScope() { return nullptr; }

void JSContext::popScope(ScopeState *) {}

const JSContext::PointerValue *
JSContext::getPointerValue(const jsa::Pointer &pointer) {
  return pointer.ptr_;
}

const JSContext::PointerValue *
JSContext::getPointerValue(const jsa::Value &value) {
  return value.data_.pointer.ptr_;
}

} // namespace jsa
} // namespace alibaba
