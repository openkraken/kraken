/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_EXPORT_H
#define KRAKEN_BRIDGE_EXPORT_H

#define KRAKEN_EXPORT                                                          \
  extern "C" __attribute__((visibility("default"))) __attribute__((used))

KRAKEN_EXPORT
void init_callback();

KRAKEN_EXPORT
void evaluate_scripts(const char *code, const char *bundleFilename,
                      int startLine);

KRAKEN_EXPORT
void reload_js_context();

#endif // KRAKEN_BRIDGE_EXPORT_H
