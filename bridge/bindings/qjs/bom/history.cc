/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "history.h"
#include "foundation/uri.h"
#include "dart_methods.h"
#include "window.h"
#include "bindings/qjs/module_manager.h"

namespace kraken::binding::qjs {

OBJECT_INSTANCE_IMPL(History);

History::History(JSContext *context) : HostObject(context, "History") {}
History::~History() {}
JSValue History::back(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *history = static_cast<History *>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  if (history->m_previous_stack.size() > 1) {
    auto &currentItem = history->m_previous_stack.top();
    history->m_previous_stack.pop();
    history->m_next_stack.push(currentItem);

    history->goTo(history->m_previous_stack.top());
    history->dispatch(history->m_previous_stack.top().state);
  }

  return JS_NULL;
}
JSValue History::forward(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *history = static_cast<History *>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));

  if (!history->m_next_stack.empty()) {
    HistoryItem &currentItem = history->m_next_stack.top();
    history->m_next_stack.pop();
    history->m_previous_stack.push(currentItem);

    history->goTo(currentItem);
    history->dispatch(currentItem.state);
  }

  return JS_NULL;
}
JSValue History::go(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  JSValue delta = JS_NULL;
  if (argc == 1) {
    delta = argv[0];
  }

  int32_t num = 0;
  if (JS_IsString(delta) || JS_IsNumber(delta)) {
    JS_ToInt32(ctx, &num, delta);
  }

  auto *history = static_cast<History *>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));

  if (num >= 0) {
    if (history->m_next_stack.size() < num) {
      return JS_NULL;
    }

    for (int i = 0; i < num; i++) {
      HistoryItem &currentItem = history->m_next_stack.top();
      history->m_next_stack.pop();
      history->m_previous_stack.push(currentItem);
    }
  } else {
    if ((history->m_previous_stack.size() - 1) < abs(num)) {
      return JS_NULL;
    }

    for (int i = 0; i < num; i++) {
      HistoryItem &currentItem = history->m_previous_stack.top();
      history->m_previous_stack.pop();
      history->m_next_stack.push(currentItem);
    }
  }

  history->goTo(history->m_previous_stack.top());

  JSValue state = history->m_previous_stack.top().state;
  history->dispatch(state);
  return JS_NULL;
}
JSValue History::pushState(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(
      ctx, "Failed to execute 'pushState' on 'History': 2 arguments required, but only %d present", argc);
  }

  auto *history = static_cast<History *>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));

  JSValue state = argv[0];
  JSValue title = argv[1];
  JSAtom urlAtom = JS_ATOM_NULL;

  if (argc >= 2) {
    JSValue urlValue = argv[2];

    std::string url = jsValueToStdString(ctx, urlValue);
    std::string strCurrentUrl = jsAtomToStdString(ctx, history->m_previous_stack.top().href);
    Uri uri = Uri::Parse(url);
    Uri currentUri = Uri::Parse(strCurrentUrl);

    if (!uri.Host.empty() && uri.Host != currentUri.Host) {
      return JS_ThrowTypeError(ctx,
                               "Failed to execute 'pushState' on 'History': A history state object with URL \"%s\" "
                               "cannot be created in a document with origin %s and URL %s. ",
                               url.c_str(), currentUri.Host.c_str(), strCurrentUrl.c_str());
    }

    if (uri.Host.empty() && uri.Protocol.empty()) {
      // Relative path.
      uri.Host = currentUri.Host;
      uri.Port = currentUri.Port;
      uri.Protocol = currentUri.Protocol;
    }

    JSValue u = JS_NewString(ctx, Uri::toString(uri).c_str());
    urlAtom = JS_ValueToAtom(ctx, u);
    JS_FreeValue(ctx, u);
  }

  HistoryItem historyItem{
    urlAtom,
    JS_DupValue(ctx, state),
    false
  };
  list_add_tail(&historyItem.link, &history->m_context->history_item_list);
  history->addItem(historyItem);
  return JS_NULL;
}
JSValue History::replaceState(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  if (argc < 2) {
    return JS_ThrowTypeError(
      ctx, "Failed to execute 'pushState' on 'History': 2 arguments required, but only %d present.", argc);
  }

  auto *history = static_cast<History *>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));

  JSValue state = argv[0];
  JSValue title = argv[1];
  JSAtom urlAtom = JS_ATOM_NULL;

  if (argc >= 2) {
    JSValue urlValue = argv[2];

    std::string url = jsValueToStdString(ctx, urlValue);
    std::string strCurrentUrl = jsAtomToStdString(ctx, history->m_previous_stack.top().href);
    Uri uri = Uri::Parse(url);
    Uri currentUri = Uri::Parse(strCurrentUrl);

    if (!uri.Host.empty() && uri.Host != currentUri.Host) {
      return JS_ThrowTypeError(ctx,
                               "Failed to execute 'pushState' on 'History': A history state object with URL \"%s\" "
                               "cannot be created in a document with origin %s and URL %s. ",
                               url.c_str(), currentUri.Host.c_str(), strCurrentUrl.c_str());
    }

    if (uri.Host.empty() && uri.Protocol.empty()) {
      // Relative path.
      uri.Host = currentUri.Host;
      uri.Port = currentUri.Port;
      uri.Protocol = currentUri.Protocol;
    }

    JSValue u = JS_NewString(ctx, Uri::toString(uri).c_str());
    urlAtom = JS_ValueToAtom(ctx, u);
    JS_FreeValue(ctx, u);
  }

  HistoryItem historyItem{
    urlAtom,
    JS_DupValue(ctx, state),
    false
  };

  history->m_previous_stack.pop();
  history->m_previous_stack.push(historyItem);
  return JS_NULL;
}
void History::addItem(HistoryItem &historyItem) {
  if (!m_previous_stack.empty() && historyItem.href == m_previous_stack.top().href) return;

  m_previous_stack.push(historyItem);

  // Clear.
  while(!m_next_stack.empty()) {
    m_next_stack.pop();
  }
}
JSAtom History::getHref() {
  if (m_previous_stack.empty()) {
    return JS_ATOM_NULL;
  }
  return m_previous_stack.top().href;
}
void History::dispatch(JSValue state) {
  auto *window = static_cast<WindowInstance *>(JS_GetOpaque(m_context->global(), Window::classId()));
  JSValue popStateEventConstructor = JS_GetPropertyStr(m_ctx, m_context->global(), "PopStateEvent");

  JSValue eventType = JS_NewString(m_ctx, "popstate");
  JSValue eventInit = JS_NewObject(m_ctx);
  JS_SetPropertyStr(m_ctx, eventInit, "state", JS_DupValue(m_ctx, state));

  JSValue arguments[] = {
    eventType,
    eventInit
  };
  JSValue popStateEvent = JS_CallConstructor(m_ctx, popStateEventConstructor, 2, arguments);
  auto *eventInstance = static_cast<EventInstance *>(JS_GetOpaque(popStateEvent, Event::kEventClassID));
  window->dispatchEvent(eventInstance);
  JS_FreeValue(m_ctx, popStateEvent);
}


void History::goTo(HistoryItem &historyItem) {
  if (!historyItem.needJump) return;

  NativeString *moduleName = stringToNativeString("Navigation");
  NativeString *method = stringToNativeString("goTo");
  NativeString *params = atomToNativeString(m_ctx, historyItem.href);

  getDartMethod()->invokeModule(nullptr, m_contextId, moduleName, method, params,
                                handleInvokeModuleUnexpectedCallback);
}

PROP_GETTER(History, length)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *history = static_cast<History *>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  return JS_NewUint32(ctx, history->m_previous_stack.size() + history->m_next_stack.size());
}

PROP_SETTER(History, length)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

PROP_GETTER(History, state)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *history = static_cast<History *>(JS_GetOpaque(this_val, JSContext::kHostObjectClassId));
  if (history->m_previous_stack.empty()) return JS_NULL;

  HistoryItem &historyItem = history->m_previous_stack.top();
  return JS_DupValue(ctx, historyItem.state);
}
PROP_SETTER(History, state)(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}

} // namespace kraken::binding::qjs
