/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_DISPATCH_RESPONSE_H
#define KRAKEN_DEBUGGER_DISPATCH_RESPONSE_H

#include "inspector/service/rpc/protocol.h"
#include <string>

namespace kraken {
namespace debugger {

class DispatchResponse {
public:
  enum Status {
    kSuccess = 0,
    kError = 1,
    kFallThrough = 2,
  };

  Status status() const {
    return m_status;
  }
  const std::string &errorMessage() const {
    return m_errorMessage;
  }
  ErrorCode errorCode() const {
    return m_errorCode;
  }
  bool isSuccess() const {
    return m_status == kSuccess;
  }

  static DispatchResponse OK();
  static DispatchResponse Error(const std::string &);
  static DispatchResponse InternalError();
  static DispatchResponse InvalidParams(const std::string &);
  static DispatchResponse FallThrough();

private:
  Status m_status;
  std::string m_errorMessage;
  ErrorCode m_errorCode;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_DISPATCH_RESPONSE_H
