/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "node_list.h"

namespace kraken::binding::qjs {

NodeList::NodeList(JSContext* context, NodeInstance* rootNode) : HostObject(context, "NodeList") {
  JS_DupValue(m_ctx, rootNode->instanceObject);
}

}  // namespace kraken::binding::qjs
