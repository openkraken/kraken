#include <functional>

using JSExceptionHandler = std::function<void(int32_t contextId, const char* errmsg)>;

#ifdef KRAKEN_ENABLE_JSA
#include "jsa.h"
#define KRAKEN_JS_CONTEXT alibaba::jsa::JSContext
#define KRAKEN_JS_VALUE alibaba::jsa::Value
#define KRAKEN_CREATE_JS_ENGINE(contextId, errorHandler, owner) alibaba::jsc::createJSContext(contextId, errorHandler, owner)
#else
#define KRAKEN_JS_CONTEXT kraken::binding::jsc::JSContext
#define KRAKEN_JS_VALUE JSValueRef
#define KRAKEN_CREATE_JS_ENGINE(contextId, errorHandler, owner) kraken::binding::jsc::createJSContext(contextId, errorHandler, owner)
#endif
