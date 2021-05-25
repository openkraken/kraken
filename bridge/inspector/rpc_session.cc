/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "rpc_session.h"

namespace kraken::debugger {

void RPCSession::handleRequest(Request req) {
  if (m_debug_session != nullptr) {
    m_debug_session->dispatchProtocolMessage(std::move(req));
  }
}

void RPCSession::handleResponse(Response response) {
  KRAKEN_LOG(VERBOSE) << "rpc session: handle response";
}

}
