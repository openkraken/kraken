/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "console.h"
#include <sstream>
#include "foundation/logging.h"

namespace kraken {

void Console::__kraken_print__(ExecutingContext* context, std::unique_ptr<NativeString>& log, std::unique_ptr<NativeString>& level, ExceptionState& exception) {
  std::stringstream stream;
  std::string buffer = nativeStringToStdString(log.get());
  stream << buffer;

  std::string logLevel = level == nullptr ? "info" : nativeStringToStdString(level.get());
  printLog(context->contextId(), stream, logLevel, nullptr);
}

}  // namespace kraken
