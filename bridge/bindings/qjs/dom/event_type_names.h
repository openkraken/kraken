/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_DOM_EVENT_TYPE_NAMES_H_
#define BRIDGE_BINDINGS_QJS_DOM_EVENT_TYPE_NAMES_H_

#include <string>
#include <vector>

namespace webf::binding::qjs {
class EventTypeNames {
 public:
  static bool isEventTypeName(const std::string& name);
};

}  // namespace webf::binding::qjs

#endif  // BRIDGE_BINDINGS_QJS_DOM_EVENT_TYPE_NAMES_H_
