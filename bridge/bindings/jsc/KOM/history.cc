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

  return nullptr;
}

JSValueRef JSHistory::forward(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                   const JSValueRef *arguments, JSValueRef *exception) {
  auto history = reinterpret_cast<JSHistory *>(JSObjectGetPrivate(function));

  if (!history->m_next_stack.empty()) {
    HistoryItem& item = history->m_next_stack.top();
    history->m_next_stack.pop();
    history->m_previous_stack.push(item);

    history->goTo(item);
  }

  return nullptr;
}

void JSHistory::goTo(HistoryItem &historyItem) {
  NativeString *moduleName = stringRefToNativeString(JSStringCreateWithUTF8CString("Navigation"));
  NativeString *method = stringRefToNativeString(JSStringCreateWithUTF8CString("goTo"));
  NativeString *params = stringRefToNativeString(JSStringCreateWithUTF8CString(historyItem.href.c_str()));

  getDartMethod()->invokeModule(nullptr, context->getContextId(), moduleName, method, params,
                                handleInvokeModuleUnexpectedCallback);
}

void JSHistory::addItem(HistoryItem &historyItem) {
  m_previous_stack.push(historyItem);

  // clear.
  while(!m_next_stack.empty()) {
    m_next_stack.pop();
  }
}

} // namespace kraken::binding::jsc
