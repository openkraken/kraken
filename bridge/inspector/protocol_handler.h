/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_PROTOCOL_HANDLER_H
#define KRAKEN_DEBUGGER_PROTOCOL_HANDLER_H

namespace kraken {
namespace debugger {
class ProtocolHandler {
public:
  virtual ~ProtocolHandler() {}
  virtual void handlePageReload() = 0;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_PROTOCOL_HANDLER_H
