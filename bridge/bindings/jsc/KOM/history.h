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
  JSStringRef href;
  JSStringRef state;
  bool needJump;
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
  static JSValueRef go(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                            const JSValueRef *arguments, JSValueRef *exception);
  static JSValueRef pushState(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                       const JSValueRef *arguments, JSValueRef *exception);
  static JSValueRef replaceState(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef *arguments, JSValueRef *exception);

  static void addItem(HistoryItem &historyItem);
  static JSStringRef getHref();
  void dispatch(JSContextRef ctx, JSStringRef state, JSValueRef *exception);

  static std::stack<HistoryItem> m_previous_stack;
  static std::stack<HistoryItem> m_next_stack;
private:
  void goTo(HistoryItem &historyItem);

private:
  JSFunctionHolder m_back{context, jsObject, this, "back", back};
  JSFunctionHolder m_forward{context, jsObject, this, "forward", forward};
  JSFunctionHolder m_go{context, jsObject, this,"go", go};
  JSFunctionHolder m_pushState{context, jsObject, this, "pushState", pushState};
  JSFunctionHolder m_replaceState{context, jsObject, this, "replaceState", replaceState};
};

void bindHistory(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_HISTORY_H
