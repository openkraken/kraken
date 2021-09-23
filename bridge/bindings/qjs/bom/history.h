/*
* Copyright (C) 2021 Alibaba Inc. All rights reserved.
* Author: Kraken Team.
*/

#ifndef KRAKENBRIDGE_HISTORY_H
#define KRAKENBRIDGE_HISTORY_H

#include "bindings/qjs/host_object.h"
#include <stack>
#include <quickjs/list.h>

namespace kraken::binding::qjs {

struct HistoryItem {
  JSAtom href;
  JSValue state;
  bool needJump;
  list_head link;
};

class History : public HostObject {
public:
  explicit History(JSContext *context);
  ~History() override;

  OBJECT_INSTANCE(History);

  static JSValue back(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue forward(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue go(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue pushState(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);
  static JSValue replaceState(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);

  void dispatch(JSValue state);

  std::stack<HistoryItem> m_previous_stack;
  std::stack<HistoryItem> m_next_stack;
private:
  DEFINE_HOST_OBJECT_PROPERTY(2, length, state);
  JSAtom getHref();
  void addItem(HistoryItem &historyItem);
  void goTo(HistoryItem &historyItem);
  ObjectFunction m_back{m_context, jsObject, "back", back, 0};
  ObjectFunction m_forward{m_context, jsObject, "forward", forward, 0};
  ObjectFunction m_go{m_context, jsObject, "go", go, 1};
  ObjectFunction m_pushState{m_context, jsObject, "pushState", pushState, 3};
  ObjectFunction m_replaceState{m_context, jsObject, "replaceState", replaceState, 3};
};

}

#endif // KRAKENBRIDGE_HISTORY_H
