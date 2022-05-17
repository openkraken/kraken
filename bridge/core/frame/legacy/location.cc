/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "location.h"
#include "core/executing_context.h"

namespace kraken {

void Location::__kraken_location_reload__(ExecutingContext* context, ExceptionState& exception_state) {
  if (context->dartMethodPtr()->reloadApp == nullptr) {
    exception_state.ThrowException(context->ctx(), ErrorType::InternalError, "Failed to execute 'reload': dart method (reloadApp) is not registered.");
    return;
  }

  context->dartMethodPtr()->flushUICommand();
  context->dartMethodPtr()->reloadApp(context->contextId());
}

}  // namespace kraken
