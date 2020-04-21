#include "bridge_callback.h"

namespace kraken {
namespace foundation {

static std::shared_ptr<BridgeCallback> _instance;

std::shared_ptr<BridgeCallback> BridgeCallback::instance() {
  if (_instance == nullptr) {
    _instance = std::make_shared<BridgeCallback>();
  }
  return _instance;
}

void BridgeCallback::disposeAllCallbacks() {
  auto lock = contextList.getLock();
  auto list = contextList.getVector();

  for (int i = 0; i < list->size(); i++) {
    std::unique_ptr<Context> context = std::move(list->back());
    context.reset();
    list->pop_back();
  }

  callbackCount = 0;
}

} // namespace foundation
} // namespace kraken
