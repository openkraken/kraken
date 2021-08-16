/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HISTORY_H
#define KRAKENBRIDGE_HISTORY_H

#include "bindings/jsc/host_object_internal.h"
#include "bindings/jsc/js_context_internal.h"
#include <array>
#include <stack>

namespace kraken::binding::jsc {

#define JSHistoryName "History"

class JSWindow;

struct HistoryItem {
  std::string href;
  std::string state;
};

class JSHistory : public HostObject {
public:
  JSHistory(JSContext *context) : HostObject(context, JSHistoryName) {}
  ~JSHistory() override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

  void back(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
            const JSValueRef *arguments, JSValueRef *exception);
  void forward(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
            const JSValueRef *arguments, JSValueRef *exception);
  void pushState(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception);
private:
  void addItem(std::string href, std::string state) {
    HistoryItem historyItem = { href, state };
    m_previous_stack.push(historyItem);
  }
  std::stack<HistoryItem> m_previous_stack;
  std::stack<HistoryItem> m_next_stack;
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_HISTORY_H
