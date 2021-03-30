/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "devtools/protocol/dispatch_response.h"

namespace kraken {
namespace debugger {

DispatchResponse DispatchResponse::OK() {
  DispatchResponse result;
  result.m_status = kSuccess;
  result.m_errorCode = jsonRpc::kParseError;
  return result;
}

DispatchResponse DispatchResponse::Error(const std::string &error) {
  DispatchResponse result;
  result.m_status = kError;
  result.m_errorCode = jsonRpc::kServerError;
  result.m_errorMessage = error;
  return result;
}

DispatchResponse DispatchResponse::InternalError() {
  DispatchResponse result;
  result.m_status = kError;
  result.m_errorCode = jsonRpc::kInternalError;
  result.m_errorMessage = "Internal error";
  return result;
}

DispatchResponse DispatchResponse::InvalidParams(const std::string &error) {
  DispatchResponse result;
  result.m_status = kError;
  result.m_errorCode = jsonRpc::kInvalidParams;
  result.m_errorMessage = error;
  return result;
}

DispatchResponse DispatchResponse::FallThrough() {
  DispatchResponse result;
  result.m_status = kFallThrough;
  result.m_errorCode = jsonRpc::kParseError;
  return result;
}

} // namespace debugger
} // namespace kraken
