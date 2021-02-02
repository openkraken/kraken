#include <JavaScriptCore/JavaScript.h>
#include <chrono>
#include <functional>

using JSExceptionHandler = std::function<void(int32_t contextId, const char *errmsg)>;

namespace kraken::binding::jsc {

class JSContext;
class JSFunctionHolder;
class JSStringHolder;
class JSValueHolder;

class JSContext {
public:
  static std::vector<JSStaticFunction> globalFunctions;
  static std::vector<JSStaticValue> globalValue;

  JSContext() = delete;
  JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
  ~JSContext();

  bool evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine);
  bool evaluateJavaScript(const char16_t *code, size_t length, const char *sourceURL, int startLine);

  bool isValid();

  JSObjectRef global();
  JSGlobalContextRef context();

  int32_t getContextId();

  void *getOwner();

  bool handleException(JSValueRef exc);

  void reportError(const char *errmsg);

  std::chrono::time_point<std::chrono::system_clock> timeOrigin;

  int32_t uniqueId;

private:
  int32_t contextId;
  JSExceptionHandler _handler;
  void *owner;
  std::atomic<bool> ctxInvalid_{false};
  JSGlobalContextRef ctx_;
};

} // namespace kraken::binding::jsc
