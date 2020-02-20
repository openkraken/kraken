/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "v8_instrumentation.h"
#include "instrumentation.h"

namespace alibaba {
namespace jsa_v8 {

void V8Instrumentation::collectGarbage() {
  v8::V8::SetFlagsFromString("--expose_gc");
  _isolate->RequestGarbageCollectionForTesting(v8::Isolate::GarbageCollectionType::kFullGarbageCollection);
}

std::string V8Instrumentation::getRecordedGCStats() { return std::string(); }

jsa::Value V8Instrumentation::getHeapInfo(bool includeExpensive) {
  return jsa::Value();
}

bool V8Instrumentation::createSnapshotToFile(const std::string &path,
                                             bool compact) {
  return false;
}

bool V8Instrumentation::createSnapshotToStream(std::ostream &os, bool compact) {
  // TODO implemented v8 snapshot
  return false;
}

void V8Instrumentation::writeBridgeTrafficTraceToFile(const std::string &fileName) const {

}

void V8Instrumentation::writeBasicBlockProfileTraceToFile(const std::string &fileName) const {

}

void V8Instrumentation::dumpProfilerSymbolsToFile(const std::string &fileName) const {

}

}
}
