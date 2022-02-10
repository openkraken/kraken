/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "console.h"
#include <sstream>
#include "foundation/logging.h"

namespace kraken {

void Console::__kraken_print__(ExecutingContext* context, ScriptValue& logValue, ScriptValue& levelValue, ExceptionState* exception) {
  std::stringstream stream;

  std::string buffer = logValue.toCString();
  stream << buffer;

  std::string logLevel = levelValue.isEmpty() ? "info" : levelValue.toCString();
  printLog(context->getContextId(), stream, logLevel, nullptr);
}

}  // namespace kraken
