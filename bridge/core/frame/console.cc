/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "console.h"
#include <sstream>
#include "built_in_string.h"
#include "foundation/logging.h"

namespace kraken {

void Console::__kraken_print__(ExecutingContext* context,
                               const AtomicString& log,
                               const AtomicString& level,
                               ExceptionState& exception) {
  std::stringstream stream;
  std::string buffer = log.ToStdString();
  stream << buffer;
  printLog(context, stream, level != built_in_string::kempty_string ? level.ToStdString() : "info", nullptr);
}

void Console::__kraken_print__(ExecutingContext* context, const AtomicString& log, ExceptionState& exception_state) {
  std::stringstream stream;
  std::string buffer = log.ToStdString();
  stream << buffer;
  printLog(context, stream, "info", nullptr);
}

}  // namespace kraken
