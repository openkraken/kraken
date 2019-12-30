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

#endif // KRAKEN_BRIDGE_EXPORT_H
