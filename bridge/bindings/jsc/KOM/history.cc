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
  } else if (name == "state") {
    HistoryItem& history = m_previous_stack.top();
    return JSValueMakeFromJSONString(ctx, history.state);
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

  if (num >= 0) {
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
  NativeString *params = stringRefToNativeString(JSValueCreateJSONString(ctx, JSValueMakeString(ctx, historyItem.href), 0, nullptr));

  getDartMethod()->invokeModule(nullptr, context->getContextId(), moduleName, method, params,
                                handleInvokeModuleUnexpectedCallback);
}

JSStringRef JSHistory::getHref() {
  return m_previous_stack.top().href;
}

void JSHistory::addItem(HistoryItem &historyItem) {
  if (!m_previous_stack.empty() && historyItem.href == m_previous_stack.top().href) return;

  m_previous_stack.push(historyItem);

  // clear.
  while(!m_next_stack.empty()) {
    m_next_stack.pop();
  }
}

JSValueRef JSHistory::pushState(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                               const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 2) {
    throwJSError(ctx,
                 ("Failed to execute 'pushState' on 'History': 2 arguments required, but only " +
                  std::to_string(argumentCount) + " present")
                   .c_str(),
                 exception);
    return nullptr;
  }

  JSValueRef state = arguments[0];
  // https://github.com/whatwg/html/issues/2174
  JSValueRef title = arguments[1];
  JSValueRef url = arguments[2];

  JSStringRef jsonState = JSValueCreateJSONString(ctx, state, 0, exception);
  JSStringRef urlRef = JSValueToStringCopy(ctx, url, exception);
  HistoryItem history = { urlRef, jsonState };

  addItem(history);

  return nullptr;
}

JSValueRef JSHistory::replaceState(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef *arguments, JSValueRef *exception) {
  if (argumentCount < 2) {
    throwJSError(ctx,
                 ("Failed to execute 'pushState' on 'History': 2 arguments required, but only " +
                  std::to_string(argumentCount) + " present")
                   .c_str(),
                 exception);
    return nullptr;
  }

  JSValueRef state = arguments[0];
  // https://github.com/whatwg/html/issues/2174
  JSValueRef title = arguments[1];
  JSValueRef url = arguments[2];

  JSStringRef jsonState = JSValueCreateJSONString(ctx, state, 0, exception);
  JSStringRef urlRef = JSValueToStringCopy(ctx, url, exception);
  HistoryItem history = { urlRef, jsonState };

  m_previous_stack.pop();
  m_previous_stack.push(history);

  return nullptr;
}

} // namespace kraken::binding::jsc
