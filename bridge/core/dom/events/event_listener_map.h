/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_DOM_EVENT_LISTENER_MAP_H_
#define KRAKENBRIDGE_BINDINGS_QJS_DOM_EVENT_LISTENER_MAP_H_

#include <quickjs/quickjs.h>
#include <vector>

#include "foundation/macros.h"
#include "bindings/qjs/atom_string.h"
#include "event_listener.h"
#include "registered_eventListener.h"

namespace kraken {

using EventListenerVector = std::vector<JSValue>;

class EventListenerMap final {
  KRAKEN_DISALLOW_NEW();
 public:
  EventListenerMap();
  ~EventListenerMap();
  EventListenerMap(const EventListenerMap&) = delete;
  EventListenerMap& operator=(const EventListenerMap&) = delete;

  bool IsEmpty() const { return m_entries.empty(); }
  bool Contains(const AtomString& event_type) const;
  bool ContainsCapturing(const AtomString& event_type) const;
  void Clear();
  bool Add(const AtomString& eventType, JSValue callback);
  bool remove(JSAtom eventType, JSValue callback);
  const EventListenerVector* find(JSAtom eventType);

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const;

 private:
  // EventListener handlers registered with addEventListener API.
  // We use vector instead of hashMap because
  //  - vector is much more space efficient than hashMap.
  //  - An EventTarget rarely has event listeners for many event types, and
  //    vector is faster in such cases.
  std::vector<std::pair<AtomString, EventListenerVector>> m_entries;

  JSRuntime* m_runtime;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_DOM_EVENT_LISTENER_MAP_H_
