/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "gc_visitor.h"

namespace kraken {

void GCVisitor::trace(JSValue value) {
  JS_MarkValue(m_runtime, value, m_markFunc);
}

}
