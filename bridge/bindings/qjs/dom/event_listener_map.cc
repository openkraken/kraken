/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_listener_map.h"

namespace kraken::binding::qjs {

static bool addListenerToVector(EventListenerVector* vector, JSValue callback) {
  if (std::find_if(vector->begin(), vector->end(), [&callback](JSValue fn) { return JS_VALUE_GET_PTR(fn) == JS_VALUE_GET_PTR(callback); }) != vector->end()) {
    return false;  // Duplicate listener.
  }

  vector->push_back(callback);
  return true;
}

static bool removeListenerFromVector(EventListenerVector* listenerVector, JSValue callback) {
  // Do a manual search for the matching listener. It is not
  // possible to create a listener on the stack because of the
  // const on |listener|.
  auto it = std::find_if(listenerVector->begin(), listenerVector->end(), [&callback](const JSValue& listener) -> bool { return JS_VALUE_GET_PTR(listener) == JS_VALUE_GET_PTR(callback); });

  if (it == listenerVector->end()) {
    return false;
  }
  listenerVector->erase(it);
  return true;
}

bool EventListenerMap::contains(JSAtom eventType) const {
  for (const auto& entry : m_entries) {
    if (entry.first == eventType)
      return true;
  }
  return false;
}

void EventListenerMap::clear() {
  m_entries.clear();
}

bool EventListenerMap::add(JSAtom eventType, JSValue callback) {
  for (const auto& entry : m_entries) {
    if (entry.first == eventType) {
      return addListenerToVector(const_cast<EventListenerVector*>(&entry.second), callback);
    }
  }

  std::vector<JSValue> list;
  list.reserve(8);
  m_entries.emplace_back(std::make_pair(eventType, list));

  return addListenerToVector(&m_entries.back().second, callback);
}

bool EventListenerMap::remove(JSAtom eventType, JSValue callback) {
  for (unsigned i = 0; i < m_entries.size(); ++i) {
    if (m_entries[i].first == eventType) {
      bool was_removed = removeListenerFromVector(&m_entries[i].second, callback);
      if (m_entries[i].second.empty()) {
        m_entries.erase(m_entries.begin() + i);
      }
      return was_removed;
    }
  }

  return false;
}

const EventListenerVector* EventListenerMap::find(JSAtom eventType) {
  for (const auto& entry : m_entries) {
    if (entry.first == eventType)
      return &entry.second;
  }

  return nullptr;
}

void EventListenerMap::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) {
  for (const auto& entry : m_entries) {
    for (const auto& vector : entry.second) {
      JS_MarkValue(rt, vector, mark_func);
    }
  }
}

}  // namespace kraken::binding::qjs
