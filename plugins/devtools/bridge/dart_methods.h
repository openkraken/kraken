/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEVTOOLS_DART_METHODS_H_
#define KRAKEN_DEVTOOLS_DART_METHODS_H_

#include "kraken_bridge.h"

#include <memory>
#include <thread>

struct NativeString;
struct Screen;

typedef void (*InspectorMessage)(int32_t contextId, const char *message);
typedef void (*InspectorMessageCallback)(void *rpcSession, const char *message);
typedef void (*RegisterInspectorMessageCallback)(int32_t contextId, void *rpcSession,
                                                 InspectorMessageCallback inspectorMessageCallback);
typedef void (*PostTaskToInspectorThread)(int32_t contextId, void *context, void (*)(void *));
typedef void (*PostTaskToUIThread)(int32_t contextId, void *context, void (*)(void *));

namespace kraken {

struct UIDartMethodPointer {
  UIDartMethodPointer() = default;
  PostTaskToInspectorThread postTaskToInspectorThread{nullptr};
};
std::shared_ptr<UIDartMethodPointer> getUIDartMethod();
void registerUIDartMethods(uint64_t *methodBytes, int32_t length);

struct InspectorDartMethodPointer {
  InspectorMessage inspectorMessage{nullptr};
  RegisterInspectorMessageCallback registerInspectorMessageCallback{nullptr};
  PostTaskToUIThread postTaskToUiThread{nullptr};
};
std::shared_ptr<InspectorDartMethodPointer> getInspectorDartMethod();
void registerInspectorDartMethods(uint64_t *methodBytes, int32_t length);

#ifdef IS_TEST
KRAKEN_EXPORT
void registerTestEnvDartMethods(uint64_t *methodBytes, int32_t length);
#endif


} // namespace kraken

#endif
