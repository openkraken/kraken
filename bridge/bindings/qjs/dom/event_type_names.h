/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_DOM_EVENT_TYPE_NAMES_H_
#define KRAKENBRIDGE_BINDINGS_QJS_DOM_EVENT_TYPE_NAMES_H_


#include <string>
#include <vector>

namespace kraken::binding::qjs {
class EventTypeNames {
 public:
  static bool isEventTypeName(const std::string& name);
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_BINDINGS_QJS_DOM_EVENT_TYPE_NAMES_H_
