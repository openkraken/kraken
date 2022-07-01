/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_HEAP_HASHMAP_H_
#define KRAKENBRIDGE_BINDINGS_QJS_HEAP_HASHMAP_H_

#include <quickjs/quickjs.h>
#include <unordered_map>

namespace kraken {

template <typename K>
class HeapHashMap {
 public:
  HeapHashMap() = delete;
  explicit HeapHashMap(JSContext* ctx);
  ~HeapHashMap();

  bool Contains(K key);
  JSValue GetProperty(K key);
  void SetProperty(K key, JSValue value);
  void CopyWith(HeapHashMap* newValue);
  void Erase(K key);

  void Trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const;

 private:
  JSRuntime* runtime_{nullptr};
  JSContext* ctx_{nullptr};
  std::unordered_map<K, JSValue> entries_;
};

template <typename K>
HeapHashMap<K>::HeapHashMap(JSContext* ctx) : runtime_(JS_GetRuntime(ctx)), ctx_(ctx) {}

template <typename K>
HeapHashMap<K>::~HeapHashMap() {
  for (auto& entry : entries_) {
    JS_FreeAtomRT(runtime_, entry.first);
    JS_FreeValueRT(runtime_, entry.second);
  }
}
template <typename K>
bool HeapHashMap<K>::Contains(K key) {
  return entries_.count(key) > 0;
}

template <typename K>
JSValue HeapHashMap<K>::GetProperty(K key) {
  if (entries_.count(key) == 0)
    return JS_NULL;

  return entries_[key];
}

template <typename K>
void HeapHashMap<K>::SetProperty(K key, JSValue value) {
  // GC can't track the value if key had been override.
  // Should free the value if exist on m_properties.
  if (entries_.count(key) > 0) {
    JS_FreeAtom(ctx_, key);
    JS_FreeValue(ctx_, entries_[key]);
  }

  entries_[key] = value;
}

template <typename K>
void HeapHashMap<K>::CopyWith(HeapHashMap* newValue) {
  for (auto& entry : entries_) {
    // We should also dup atom if K is JSAtom.
    if (std::is_same<K, JSAtom>::value) {
      JS_DupAtom(ctx_, entry.first);
    }

    newValue->entries_[entry.first] = JS_DupValue(ctx_, entry.second);
  }
}

template <typename K>
void HeapHashMap<K>::Erase(K key) {
  if (entries_.count(key) == 0)
    return;
  // We should also free atom if K is JSAtom.
  if (std::is_same<K, JSAtom>::value) {
    JS_FreeAtomRT(runtime_, key);
  }
  JS_FreeValueRT(runtime_, entries_[key]);
  entries_.erase(key);
}

template <typename K>
void HeapHashMap<K>::Trace(JSRuntime* rt, JSValue val, JS_MarkFunc* mark_func) const {
  for (auto& entry : entries_) {
    JS_MarkValue(rt, entry.second, mark_func);
  }
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_HEAP_HASHMAP_H_
