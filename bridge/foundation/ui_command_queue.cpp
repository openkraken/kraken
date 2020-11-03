/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "ui_command_queue.h"

namespace foundation {

void UICommandTaskMessageQueue::registerCommand(int64_t id, int8_t type, NativeString **args, size_t length, int64_t nativePtr) {
  auto item = new UICommandItem(id, type, args, length, nativePtr);
  queue.emplace_back(item);
}

}

