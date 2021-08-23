/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "history.h"
#include "dart_methods.h"

namespace kraken::binding::jsc {

std::stack<HistoryItem> JSHistory::m_previous_stack {};

std::stack<HistoryItem> JSHistory::m_next_stack {};

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

  if (m_previous_stack.size() > 1) {
    HistoryItem& currentItem = m_previous_stack.top();
    m_previous_stack.pop();
    m_next_stack.push(currentItem);

    history->goTo(m_previous_stack.top());
  }

  return nullptr;
}

JSValueRef JSHistory::forward(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                   const JSValueRef *arguments, JSValueRef *exception) {
  auto history = reinterpret_cast<JSHistory *>(JSObjectGetPrivate(function));

  if (!m_next_stack.empty()) {
    HistoryItem& currentItem = m_next_stack.top();
    m_next_stack.pop();
    m_previous_stack.push(currentItem);

    history->goTo(currentItem);
  }

  return nullptr;
}

JSValueRef JSHistory::go(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                              const JSValueRef *arguments, JSValueRef *exception) {
  JSValueRef value = arguments[0];
  int num = 0;
  if (JSValueIsString(ctx, value) || JSValueIsNumber(ctx, value)) {
    num = JSValueToNumber(ctx, value, exception);
  }

  auto history = reinterpret_cast<JSHistory *>(JSObjectGetPrivate(function));

  if (num > 0) {
    if (m_next_stack.size() < num) {
      return nullptr;
    }

    for (int i = 0; i < num; i++) {
      HistoryItem& currentItem = m_next_stack.top();
      m_next_stack.pop();
      m_previous_stack.push(currentItem);
    }
  } else {
    if ((m_previous_stack.size() - 1) < abs(num)) {
      return nullptr;
    }

    for (int i = 0; i < num; i++) {
      HistoryItem& currentItem = m_previous_stack.top();
      m_previous_stack.pop();
      m_next_stack.push(currentItem);
    }
  }

  history->goTo(m_previous_stack.top());

  return nullptr;
}

void JSHistory::goTo(HistoryItem &historyItem) {
  NativeString *moduleName = stringRefToNativeString(JSStringCreateWithUTF8CString("Navigation"));
  NativeString *method = stringRefToNativeString(JSStringCreateWithUTF8CString("goTo"));
  NativeString *params = stringRefToNativeString(JSValueCreateJSONString(ctx, JSValueMakeString(ctx, JSStringCreateWithUTF8CString(historyItem.href.c_str())), 0, nullptr));

  getDartMethod()->invokeModule(nullptr, context->getContextId(), moduleName, method, params,
                                handleInvokeModuleUnexpectedCallback);
}

void JSHistory::addItem(HistoryItem &historyItem) {
  if (!m_previous_stack.empty() && historyItem.href == m_previous_stack.top().href) return;

  m_previous_stack.push(historyItem);

  // clear.
  while(!m_next_stack.empty()) {
    m_next_stack.pop();
  }
}

} // namespace kraken::binding::jsc
