/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_PAGE_BACKEND_H
#define KRAKEN_DEBUGGER_PAGE_BACKEND_H

#include "inspector/protocol/dispatch_response.h"
#include "inspector/protocol/maybe.h"
#include <string>

namespace kraken {
namespace debugger {
class PageBackend {
public:
  virtual ~PageBackend() {}

  virtual DispatchResponse disable() = 0;
  virtual DispatchResponse enable() = 0;

  virtual DispatchResponse reload(Maybe<bool> in_ignoreCache, Maybe<std::string> in_scriptToEvaluateOnLoad) = 0;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_PAGE_BACKEND_H
