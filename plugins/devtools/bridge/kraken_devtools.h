/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEVTOOLS_KRAKEN_DEVTOOLS_H
#define KRAKEN_DEVTOOLS_KRAKEN_DEVTOOLS_H

#include <cinttypes>
#include "kraken_bridge.h"
#include "inspector/protocol_handler.h"
#include <JavaScriptCore/JavaScript.h>
#include "dart_methods.h"

namespace kraken::debugger {

class BridgeProtocolHandler : public ProtocolHandler {
public:
  BridgeProtocolHandler() {};

  ~BridgeProtocolHandler() {};

  void handlePageReload() override;

private:
};
}

KRAKEN_EXPORT_C
void attachInspector(int32_t contextId);
KRAKEN_EXPORT_C
void registerInspectorDartMethods(uint64_t *methodBytes, int32_t length);

KRAKEN_EXPORT_C
void registerUIDartMethods(uint64_t *methodBytes, int32_t length);

KRAKEN_EXPORT_C
void dispatchInspectorTask(int32_t contextId, void *context, void *callback);

#endif //KRAKEN_DEVTOOLS_KRAKEN_DEVTOOLS_H
