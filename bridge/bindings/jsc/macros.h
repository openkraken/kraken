#define KRAKEN_BINDING_CONSOLE "__kraken_print__"

#define JSC_BINDING_FUNCTION(context, nameStr, func)                                                                                          \
  JSStringRef name = JSStringCreateWithUTF8CString(nameStr);                                             \
  context->emplaceGlobalString(name);                                                                                   \
  JSObjectRef function = JSObjectMakeFunctionWithCallback(context->context(), name, func);                             \
  JSValueRef exc = nullptr;                                                                                             \
  JSObjectSetProperty(context->context(), context->global(), name, function, kJSPropertyAttributeNone, &exc);           \
  context->handleException(exc);
