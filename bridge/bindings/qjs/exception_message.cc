/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "exception_message.h"
#include <vector>

namespace kraken {

std::string ExceptionMessage::FormatString(const char* format, ...) {
  va_list args;

  static const unsigned kDefaultSize = 256;
  std::vector<char> buffer(kDefaultSize);
  buffer.reserve(kDefaultSize);

  va_start(args, format);
  int length = vsnprintf(buffer.data(), buffer.size(), format, args);
  va_end(args);

  if (length < 0)
    return "";

  if (static_cast<unsigned>(length) >= buffer.size()) {
    // vsnprintf doesn't include the NUL terminator in the length so we need to
    // add space for it when growing.
    buffer.reserve(length + 1);

    // We need to call va_end() and then va_start() each time we use args, as
    // the contents of args is undefined after the call to vsnprintf according
    // to http://man.cx/snprintf(3)
    //
    // Not calling va_end/va_start here happens to work on lots of systems, but
    // fails e.g. on 64bit Linux.
    va_start(args, format);
    length = vsnprintf(buffer.data(), buffer.size(), format, args);
    va_end(args);
  }

  assert(static_cast<unsigned>(length) <= buffer.size());
  return std::string(buffer.data(), length);
}

std::string ExceptionMessage::ArgumentNotOfType(int argument_index, const char* expected_type) {
  return FormatString("parameter %d is not of type '%s'.", argument_index + 1, expected_type);
}

std::string ExceptionMessage::ArgumentNullOrIncorrectType(int argument_index, const char* expect_type) {
  return FormatString("The %d argument provided is either null, or an invalid %s object.", argument_index, expect_type);
}

}  // namespace kraken
