/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_DOM_EVENT_LISTENER_MAP_H_
#define KRAKENBRIDGE_BINDINGS_QJS_DOM_EVENT_LISTENER_MAP_H_

#include <quickjs/quickjs.h>
#include <vector>
#include "include/kraken_foundation.h"

namespace kraken::binding::qjs {

using EventListenerVector = std::vector<JSValue>;

class EventListenerMap final {
 public:
  EventListenerMap(JSContext* ctx) : m_runtime(JS_GetRuntime(ctx)){};
  ~EventListenerMap();

  [[nodiscard]] bool empty() const { return m_entries.empty(); }
  [[nodiscard]] bool contains(JSAtom eventType) const;
  void clear();
  bool add(JSAtom eventType, JSValue callback);
  bool remove(JSAtom eventType, JSValue callback);
  const EventListenerVector* find(JSAtom eventType);

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func);

 private:
  // EventListener handlers registered with addEventListener API.
  // We use vector instead of hashMap because
  //  - vector is much more space efficient than hashMap.
  //  - An EventTarget rarely has event listeners for many event types, and
  //    vector is faster in such cases.
  std::vector<std::pair<JSAtom, EventListenerVector>> m_entries;

  JSRuntime* m_runtime;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_BINDINGS_QJS_DOM_EVENT_LISTENER_MAP_H_
