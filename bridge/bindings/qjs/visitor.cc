/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "visitor.h"

namespace kraken {

void Visitor::trace(JSValue value) {
  JS_MarkValue(m_runtime, value, m_markFunc);
}

}
