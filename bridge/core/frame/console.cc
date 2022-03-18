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
  printLog(context->contextId(), stream, nativeStringToStdString(level.get()), nullptr);
}

void Console::__kraken_print__(ExecutingContext* context, std::unique_ptr<NativeString>& log, ExceptionState& exception_state) {
  std::stringstream stream;
  std::string buffer = nativeStringToStdString(log.get());
  stream << buffer;
  printLog(context->contextId(), stream, "info", nullptr);
}

}  // namespace kraken
