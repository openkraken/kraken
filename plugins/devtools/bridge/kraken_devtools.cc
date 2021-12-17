/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "kraken_devtools.h"
#include "kraken_bridge.h"
#include "inspector/frontdoor.h"
#include "dart_methods.h"
#include <memory>

void attachInspector(int32_t contextId) {
  JSGlobalContextRef ctx = getGlobalContextRef(contextId);
  std::shared_ptr<kraken::debugger::BridgeProtocolHandler> handler = std::make_shared<kraken::debugger::BridgeProtocolHandler>();
  JSC::ExecState* exec = toJS(ctx);
  JSC::VM& vm = exec->vm();
  JSC::JSLockHolder locker(vm);
  JSC::JSGlobalObject* globalObject = vm.vmEntryGlobalObject(exec);
  auto *frontDoor = new kraken::debugger::FrontDoor(contextId, ctx, globalObject->globalObject(), handler);
  registerContextDisposedCallbacks(contextId, [](void *ptr) {
    delete reinterpret_cast<kraken::debugger::FrontDoor *>(ptr);
  }, frontDoor);

  setConsoleMessageHandler(kraken::debugger::FrontDoor::handleConsoleMessage);
}

void dispatchInspectorTask(int32_t contextId, void *context, void *callback) {
  assert(std::this_thread::get_id() != getUIThreadId());
  reinterpret_cast<void(*)(void*)>(callback)(context);
}

void registerInspectorDartMethods(uint64_t *methodBytes, int32_t length) {
  kraken::registerInspectorDartMethods(methodBytes, length);
}

void registerUIDartMethods(uint64_t *methodBytes, int32_t length) {
  kraken::registerUIDartMethods(methodBytes, length);
}

namespace kraken::debugger {

void BridgeProtocolHandler::handlePageReload() {
  // FIXME: reload with devtolls are not full working yet (debugger not working).
  // getDartMethod()->flushUICommand();
  // getDartMethod()->reloadApp(m_bridge->contextId);
}

}
