/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "script_value.h"

namespace kraken {

bool ScriptValue::isEmpty() {
  return JS_IsNull(m_value);
}

JSValue ScriptValue::toQuickJS() {
  return m_value;
}

bool ScriptValue::isException() {
  return JS_IsException(m_value);
}

}
