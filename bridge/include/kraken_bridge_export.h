/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_EXPORT_H
#define KRAKEN_BRIDGE_EXPORT_H

#define KRAKEN_EXPORT                                                          \
  extern "C" __attribute__((visibility("default"))) __attribute__((used))

KRAKEN_EXPORT
void initJsEngine();

KRAKEN_EXPORT
void evaluateScripts(const char *code, const char *bundleFilename,
                      int startLine);

KRAKEN_EXPORT
void reloadJsContext();

KRAKEN_EXPORT
void registerInvokeDartFromJS(const char* (*callbacks)(const char*));

KRAKEN_EXPORT
void registerReloadApp(void (*callback)());

#endif // KRAKEN_BRIDGE_EXPORT_H
