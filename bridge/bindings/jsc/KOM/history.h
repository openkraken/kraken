/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HISTORY_H
#define KRAKENBRIDGE_HISTORY_H

#include "bindings/jsc/host_object_internal.h"
#include "bindings/jsc/js_context_internal.h"
#include "bindings/jsc/ui_manager.h"
#include <array>
#include <stack>

namespace kraken::binding::jsc {

#define JSHistoryName "History"

class JSWindow;

struct HistoryItem {
  std::string href;
  JSValueRef state;
};

class JSHistory : public HostObject {
public:
  JSHistory(JSContext *context) : HostObject(context, JSHistoryName) {}
  ~JSHistory() override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

  static JSValueRef back(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef *arguments, JSValueRef *exception);
  static JSValueRef forward(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                  const JSValueRef *arguments, JSValueRef *exception);
private:
  void goTo(HistoryItem &historyItem);
  void addItem(HistoryItem &historyItem);
  std::stack<HistoryItem> m_previous_stack;
  std::stack<HistoryItem> m_next_stack;

private:
  JSFunctionHolder m_back{context, jsObject, this,"back", back};
  JSFunctionHolder m_forward{context, jsObject, this,"forward", forward};
};

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_HISTORY_H
