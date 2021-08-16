/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "history.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

JSHistory::~JSHistory() {
}

JSValueRef JSHistory::getProperty(std::string &name, JSValueRef *exception) {
  if (name == "length") {
    return JSValueMakeNumber(context->context(), m_previous_stack.size() + m_next_stack.size());
  }

  return HostObject::getProperty(name, exception);
}

JSValueRef JSHistory::back(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef *arguments, JSValueRef *exception) {
  auto history = reinterpret_cast<JSHistory *>(JSObjectGetPrivate(function));

  if (!history->m_previous_stack.empty()) {
    HistoryItem& item = history->m_previous_stack.top();
    history->m_previous_stack.pop();
    history->m_next_stack.push(item);
  }
}

JSValueRef JSHistory::forward(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                   const JSValueRef *arguments, JSValueRef *exception) {
  auto history = reinterpret_cast<JSHistory *>(JSObjectGetPrivate(function));

  if (!history->m_next_stack.empty()) {
    HistoryItem& item = history->m_next_stack.top();
    history->m_next_stack.pop();
    history->m_previous_stack.push(item);
  }
}

} // namespace kraken::binding::jsc
