/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "history.h"
#include "dart_methods.h"
#include "bindings/jsc/KOM/window.h"
#include "bindings/jsc/DOM/document.h"

namespace kraken::binding::jsc {

struct Uri
{
public:
  std::string QueryString, Path, Protocol, Host, Port;

  static std::string toString(Uri& uri) {
    return uri.Protocol + "://" + uri.Host + (uri.Port == "" ? "" : ":" + uri.Port) + uri.Path + uri.QueryString;
  }

  static Uri Parse(const std::string &uri)
  {
    Uri result;

    typedef std::string::const_iterator iterator_t;

    if (uri.length() == 0)
      return result;

    iterator_t uriEnd = uri.end();

    // get query start
    iterator_t queryStart = std::find(uri.begin(), uriEnd, '?');

    // protocol
    iterator_t protocolStart = uri.begin();
    iterator_t protocolEnd = std::find(protocolStart, uriEnd, ':');            //"://");

    if (protocolEnd != uriEnd)
    {
      std::string prot = &*(protocolEnd);
      if ((prot.length() > 3) && (prot.substr(0, 3) == "://"))
      {
        result.Protocol = std::string(protocolStart, protocolEnd);
        protocolEnd += 3;   //      ://
      }
      else
        protocolEnd = uri.begin();  // no protocol
    }
    else
      protocolEnd = uri.begin();  // no protocol

    // host
    iterator_t hostStart = protocolEnd;
    iterator_t pathStart = std::find(hostStart, uriEnd, '/');  // get pathStart

    iterator_t hostEnd = std::find(protocolEnd,
                                   (pathStart != uriEnd) ? pathStart : queryStart,
                                   ':');  // check for port

    result.Host = std::string(hostStart, hostEnd);

    // port
    if ((hostEnd != uriEnd) && ((&*(hostEnd))[0] == ':'))  // we have a port
    {
      hostEnd++;
      iterator_t portEnd = (pathStart != uriEnd) ? pathStart : queryStart;
      result.Port = std::string(hostEnd, portEnd);
    }

    // path
    if (pathStart != uriEnd)
      result.Path = std::string(pathStart, queryStart);

    // query
    if (queryStart != uriEnd)
      result.QueryString = std::string(queryStart, uri.end());

    return result;

  }   // Parse
};  // uri

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

    JSStringRef &state = m_previous_stack.top().state;
    history->dispatch(ctx, state == nullptr ? nullptr : JSValueMakeFromJSONString(ctx, state), exception);
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

    JSStringRef &state = currentItem.state;
    history->dispatch(ctx, state == nullptr ? nullptr : JSValueMakeFromJSONString(ctx, state), exception);
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

  JSStringRef state = m_previous_stack.top().state;
  history->dispatch(ctx, state == nullptr ? nullptr : JSValueMakeFromJSONString(ctx, state), exception);

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
  if (m_previous_stack.empty()) {
    return JSStringCreateWithUTF8CString("");
  }
  return m_previous_stack.top().href;
}

void JSHistory::dispatch(JSContextRef ctx, JSValueRef state, JSValueRef *exception) {
  JSStringHolder windowKeyHolder = JSStringHolder(context, "window");
  JSValueRef windowValue = JSObjectGetProperty(ctx, context->global(), windowKeyHolder.getString(), nullptr);
  JSObjectRef windowObject = JSValueToObject(context->context(), windowValue, nullptr);

  auto window = static_cast<WindowInstance *>(JSObjectGetPrivate(windowObject));

  JSObjectRef eventInit = JSObjectRef();
  if (JSValueIsUndefined(ctx, state)) {
    JSObjectSetProperty(ctx, eventInit, JSStringCreateWithUTF8CString("state"), state, kJSPropertyAttributeNone, exception);
  }
  EventInstance *eventInstance = new PopStateEventInstance(JSPopStateEvent::instance(context), "popstate", eventInit, exception);
  window->dispatchEvent(eventInstance);
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
  // https://github.com/whatwg/hpushStatetml/issues/2174
  JSValueRef title = arguments[1];
  JSValueRef url = arguments[2];
  JSStringRef urlRef = JSValueToStringCopy(ctx, url, exception);

  std::string strUrl = JSStringToStdString(urlRef);
  std::string strCurrentUrl = JSStringToStdString(m_previous_stack.top().href);

  Uri uri = Uri::Parse(strUrl);
  Uri currentUri = Uri::Parse(strCurrentUrl);

  if (uri.Host != "" && uri.Host != currentUri.Host) {
    throwJSError(ctx,
                 ("Failed to execute 'pushState' on 'History': A history state object with URL " + strUrl +
                  " cannot be created in a document with origin " + currentUri.Host + "  and URL " + strCurrentUrl + ".").c_str(),
                 exception);
  }

  JSStringRef jsonState = JSValueCreateJSONString(ctx, state, 0, exception);

  if (strUrl.find("/") == 0) {
    uri.Host = currentUri.Host;
    uri.Port = currentUri.Port;
    uri.Protocol = currentUri.Protocol;
  }

  HistoryItem history = { JSStringCreateWithUTF8CString(Uri::toString(uri).c_str()), jsonState };
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
