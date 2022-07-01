/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_EXCEPTION_MESSAGE_H_
#define KRAKENBRIDGE_BINDINGS_QJS_EXCEPTION_MESSAGE_H_

#include <string>

namespace kraken {

class ExceptionMessage {
 public:
  static std::string FormatString(const char* format, ...);

  static std::string ArgumentNotOfType(int argument_index, const char* expect_type);
  static std::string ArgumentNullOrIncorrectType(int argument_index, const char* expect_type);

 private:
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_EXCEPTION_MESSAGE_H_
