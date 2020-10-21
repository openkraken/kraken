/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "element.h"
#include "dart_methods.h"
#include "foundation/ui_command_queue.h"

namespace kraken::binding::jsc {
using namespace foundation;

JSElement::JSElement(JSContext *context, NativeString *tagName) : JSNode(context, "Element", NodeType::ELEMENT_NODE) {
  const int32_t argsLength = 1;
  NativeString **args = new NativeString *[argsLength];
  args[0] = tagName;
  UICommandTaskMessageQueue::instance(context->getContextId())
    ->registerCommand(getEventTargetId(), UICommandType::createElement, args, argsLength);
}

} // namespace kraken::binding::jsc
