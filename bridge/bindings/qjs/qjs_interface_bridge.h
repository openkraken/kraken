/*
 * Copyright (C) 2020-present Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_QJS_INTERFACE_BRIDGE_H_
#define KRAKENBRIDGE_BINDINGS_QJS_QJS_INTERFACE_BRIDGE_H_

#include "script_wrappable.h"

namespace kraken {

template <class QJST, class T>
class QJSInterfaceBridge {
 public:
  static T* ToWrappable(ExecutingContext* context, JSValue value) {
    return HasInstance(context, value) ? toScriptWrappable<T>(value) : nullptr;
  }

  static bool HasInstance(ExecutingContext* context, JSValue value);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_QJS_INTERFACE_BRIDGE_H_
