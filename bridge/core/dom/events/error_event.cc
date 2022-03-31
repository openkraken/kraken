/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "error_event.h"

namespace kraken {

ErrorEventInit::ErrorEventInit(JSContext* ctx, JSValue value, ExceptionState& exception_state) {
  FillMembersWithQJSObject(ctx, value, exception_state);
}

bool ErrorEventInit::FillQJSObjectWithMembers(JSContext* ctx, JSValue qjs_dictionary) const {
  return false;
}

void ErrorEventInit::FillMembersWithQJSObject(JSContext* ctx, JSValue value, ExceptionState& exception_state) {}

}

