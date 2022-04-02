/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "event_listener_map.h"

namespace kraken {

static bool AddListenerToVector(EventListenerVector* vector,
                                const std::shared_ptr<EventListener>& listener,
                                const std::shared_ptr<AddEventListenerOptions>& options,
                                RegisteredEventListener* registered_event_listener) {
  *registered_event_listener = RegisteredEventListener(listener, options);

  if (std::find(vector->begin(), vector->end(), *registered_event_listener) != vector->end()) {
    return false;  // Duplicate listener.
  }

  vector->push_back(*registered_event_listener);
  return true;
}

static bool RemoveListenerFromVector(EventListenerVector* listener_vector,
                                     const std::shared_ptr<EventListener>& listener,
                                     const std::shared_ptr<EventListenerOptions>& options,
                                     size_t* index_of_removed_listener,
                                     RegisteredEventListener* registered_event_listener) {
  // Do a manual search for the matching listener. It is not
  // possible to create a listener on the stack because of the
  // const on |listener|.
  auto it = std::find_if(listener_vector->begin(), listener_vector->end(), [listener, options](const RegisteredEventListener& event_listener) -> bool { return event_listener.Matches(listener, options); });

  if (it == listener_vector->end()) {
    *index_of_removed_listener = -1;
    return false;
  }

  *registered_event_listener = *it;
  *index_of_removed_listener = it - listener_vector->begin();
  listener_vector->erase(it);

  return true;
}

bool EventListenerMap::Contains(const AtomicString& event_type) const {
  for (const auto& entry : entries_) {
    if (entry.first == event_type)
      return true;
  }
  return false;
}

bool EventListenerMap::ContainsCapturing(const AtomicString& event_type) const {
  for (const auto& entry : entries_) {
    if (entry.first == event_type) {
      for (const auto& event_listener : *entry.second) {
        if (event_listener.Capture())
          return true;
      }
      return false;
    }
  }
  return false;
}

void EventListenerMap::Clear() {
  entries_.clear();
}

bool EventListenerMap::Add(const AtomicString& event_type,
                           const std::shared_ptr<EventListener>& listener,
                           const std::shared_ptr<AddEventListenerOptions>& options,
                           RegisteredEventListener* registered_event_listener) {
  for (const auto& entry : entries_) {
    if (entry.first == event_type)
      return AddListenerToVector(entry.second.get(), listener, options, registered_event_listener);
  }

  entries_.emplace_back(event_type, std::make_unique<EventListenerVector>());
  return AddListenerToVector(entries_.back().second.get(), listener, options, registered_event_listener);
}

bool EventListenerMap::Remove(const AtomicString& event_type,
                              const std::shared_ptr<EventListener>& listener,
                              const std::shared_ptr<EventListenerOptions>& options,
                              size_t* index_of_removed_listener,
                              RegisteredEventListener* registered_event_listener) {
  for (unsigned i = 0; i < entries_.size(); ++i) {
    if (entries_[i].first == event_type) {
      bool was_removed = RemoveListenerFromVector(entries_[i].second.get(), listener, options, index_of_removed_listener, registered_event_listener);
      if (entries_[i].second->empty()) {
        entries_.erase(entries_.begin() + i);
      }
      return was_removed;
    }
  }

  return false;
}

EventListenerVector* EventListenerMap::Find(const AtomicString& event_type) {
  for (const auto& entry : entries_) {
    if (entry.first == event_type)
      return entry.second.get();
  }

  return nullptr;
}

}  // namespace kraken
