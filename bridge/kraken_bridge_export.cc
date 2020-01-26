/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge_export.h"
#include "dart_callbacks.h"
#include "bridge.h"
#include "polyfill.h"
#include <atomic>
#include <string>

kraken::DartFuncPointer funcPointer;
// this is not thread safe
std::atomic<bool> inited{false};
std::unique_ptr<kraken::JSBridge> bridge;

void reloadJsContext() {
  inited = false;
  bridge = std::make_unique<kraken::JSBridge>();
  initKrakenPolyFill(bridge->getContext());
  inited = true;
}

void initJsEngine() {
  bridge = std::make_unique<kraken::JSBridge>();
  inited = true;
}

void evaluateScripts(const char *code, const char *bundleFilename,
                      int startLine) {
  if (!inited) return;
  bridge->evaluateScript(std::string(code), std::string(bundleFilename),
                         startLine);
}

void registerInvokeDartFromJS(InvokeDartFromJS callbacks) {
  kraken::registerInvokeDartFromJS(callbacks);
}
