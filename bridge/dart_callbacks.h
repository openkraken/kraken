/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DART_CALLBACKS_H_
#define KRAKEN_DART_CALLBACKS_H_

#include "thread_safe_map.h"
#include <memory>

typedef const char *(*InvokeDartFromJS)(const char *);

namespace kraken {

struct DartFuncPointer {
  DartFuncPointer() : invokeDartFromJS(nullptr) {}
  InvokeDartFromJS invokeDartFromJS;
};

void registerInvokeDartFromJS(InvokeDartFromJS callback);

DartFuncPointer* getDartFunc();

} // namespace kraken

#endif
