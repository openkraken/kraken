/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */
#ifndef KRAKENBRIDGE_V8_INSTRUMENTATION_H
#define KRAKENBRIDGE_V8_INSTRUMENTATION_H

#include "instrumentation.h"
#include <v8.h>

namespace alibaba {
namespace jsa_v8 {

class V8Instrumentation : public jsa::Instrumentation {
public:
  V8Instrumentation(v8::Isolate *isolate) : _isolate(isolate){};
  ~V8Instrumentation(){};

  std::string getRecordedGCStats() override;

  jsa::Value getHeapInfo(bool includeExpensive) override;

  void collectGarbage() override;

  bool createSnapshotToFile(const std::string &path, bool compact) override;

  bool createSnapshotToStream(std::ostream &os, bool compact) override;

  void writeBridgeTrafficTraceToFile(const std::string &fileName) const override;

  void writeBasicBlockProfileTraceToFile(const std::string &fileName) const override;

  void dumpProfilerSymbolsToFile(const std::string &fileName) const override;

private:
  v8::Isolate *_isolate;
};

} // namespace jsa_v8
} // namespace alibaba

#endif // KRAKENBRIDGE_V8_INSTRUMENTATION_H
