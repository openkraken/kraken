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

void JSHistory::back(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
          const JSValueRef *arguments, JSValueRef *exception) {
  if (!m_previous_stack.empty()) {
    HistoryItem& item = m_previous_stack.top();
    m_previous_stack.pop();
    m_next_stack.push(item);
  }
}

void JSHistory::forward(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                     const JSValueRef *arguments, JSValueRef *exception) {
  if (!m_next_stack.empty()) {
    HistoryItem& item = m_next_stack.top();
    m_next_stack.pop();
    m_previous_stack.push(item);
  }
}

void JSHistory::pushState(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef *arguments, JSValueRef *exception) {
}

} // namespace kraken::binding::jsc
