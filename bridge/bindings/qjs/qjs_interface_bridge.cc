/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "qjs_interface_bridge.h"
#include "core/executing_context.h"

namespace kraken {

template <class QJST, class T>
bool QJSInterfaceBridge<QJST, T>::HasInstance(ExecutingContext* context, JSValue value) {
  return JS_IsInstanceOf(context->ctx(), value, context->contextData()->prototypeForType(QJST::GetWrapperTypeInfo()));
}

}  // namespace kraken
