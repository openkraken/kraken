/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_bridge_export.h"
#include "kraken_hook_init.h"
#include "bridge.h"
#include "polyfill.h"
#include <string>
#include <atomic>
std::atomic<bool> inited;

static kraken::JSBridge *bridge = new kraken::JSBridge();

// injected into engine
void invoke_kraken_callback(const char* args) {
  bridge->handleFlutterCallback(args);
}

// injected into engine
void evaluate_scripts(const char* code, const char* bundleFilename, int startLine) {
  bridge->evaluateScript(std::string(code), std::string(bundleFilename), startLine);
}

KRAKEN_EXPORT
void init_callback() {
  if (inited) return;
  inited = true;

  KrakenInitCallBack(invoke_kraken_callback);
  KrakenInitEvaluateScriptCallback(evaluate_scripts);
  initKrakenPolyFill(bridge->getContext());
}
