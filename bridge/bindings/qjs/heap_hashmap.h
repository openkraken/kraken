/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_HEAP_HASHMAP_H_
#define KRAKENBRIDGE_BINDINGS_QJS_HEAP_HASHMAP_H_

#include <quickjs/quickjs.h>
#include <unordered_map>

namespace kraken::binding::qjs {

template <typename K>
class HeapHashMap {
 public:
  HeapHashMap() = delete;
  explicit HeapHashMap(JSContext* ctx);
  ~HeapHashMap();

  bool contains(K key);
  JSValue getProperty(K key);
  void setProperty(K key, JSValue value);
  void copyWith(HeapHashMap* newValue);
  void erase(K key);

  void trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const;

 private:
  JSRuntime* m_runtime{nullptr};
  JSContext* m_ctx{nullptr};
  std::unordered_map<K, JSValue> m_entries;
};

template <typename K>
HeapHashMap<K>::HeapHashMap(JSContext* ctx) : m_runtime(JS_GetRuntime(ctx)), m_ctx(ctx) {}

template <typename K>
HeapHashMap<K>::~HeapHashMap() {
  for (auto& entry : m_entries) {
    JS_FreeValueRT(m_runtime, entry.second);
  }
}
template <typename K>
bool HeapHashMap<K>::contains(K key) {
  return m_entries.count(key) > 0;
}

template <typename K>
JSValue HeapHashMap<K>::getProperty(K key) {
  return m_entries[key];
}

template <typename K>
void HeapHashMap<K>::setProperty(K key, JSValue value) {
  m_entries[key] = value;
}

template <typename K>
void HeapHashMap<K>::copyWith(HeapHashMap* newValue) {
  for (auto& entry : m_entries) {
    newValue->m_entries[entry.first] = JS_DupValue(m_ctx, entry.second);
  }
}

template <typename K>
void HeapHashMap<K>::erase(K key) {
  m_entries.erase(key);
}

template <typename K>
void HeapHashMap<K>::trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  for (auto& entry : m_entries) {
    JS_MarkValue(rt, entry.second, mark_func);
  }
}

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_BINDINGS_QJS_HEAP_HASHMAP_H_
