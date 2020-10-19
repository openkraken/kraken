
using JSExceptionHandler = std::function<void(int32_t contextId, const char* errmsg)>;

#ifdef KRAKEN_ENABLE_JSA
#include "jsa.h"
#define KRAKEN_JS_CONTEXT alibaba::jsa::JSContext
#define KRAKEN_JS_VALUE alibaba::jsa::Value
#define KRAKEN_CREATE_JS_ENGINE(contextId, errorHandler, owner) alibaba::jsc::createJSContext(contextId, errorHandler, owner)
#else
#endif
