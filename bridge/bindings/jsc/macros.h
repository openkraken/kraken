#define KRAKEN_BINDING_CONSOLE "__kraken_print__"

#define JSC_BINDING_FUNCTION(context, nameStr, func)                                                                                          \
  JSStringRef name = JSStringCreateWithUTF8CString(nameStr);                                             \
  context->emplaceGlobalString(name);                                                                                   \
  JSObjectRef function = JSObjectMakeFunctionWithCallback(context->context(), name, func);                              \
  JSValueRef exc = nullptr;                                                                                             \
  JSObjectSetProperty(context->context(), context->global(), name, function, kJSPropertyAttributeNone, &exc);           \
  context->handleException(exc);

#define HANDLE_JSC_EXCEPTION(ctx_, exc, handler)                                                                        \
  JSObjectRef error = JSValueToObject(ctx_, exc, nullptr);                                                              \
  JSStringRef messageKey = JSStringCreateWithUTF8CString("message");                                                    \
  JSStringRef stackKey = JSStringCreateWithUTF8CString("stack");                                                        \
  JSValueRef messageRef = JSObjectGetProperty(ctx_, error, messageKey, nullptr);                                        \
  JSValueRef stackRef = JSObjectGetProperty(ctx_, error, stackKey, nullptr);                                            \
  JSStringRef messageStr = JSValueToStringCopy(ctx_, messageRef, nullptr);                                              \
  JSStringRef stackStr = JSValueToStringCopy(ctx_, stackRef, nullptr);                                                  \
  std::string message = JSStringToStdString(messageStr);                                                                \
  std::string stack = JSStringToStdString(stackStr);                                                                    \
  handler(getContextId(), (message + '\n' + stack).c_str());                                                            \
  JSStringRelease(messageKey);                                                                                          \
  JSStringRelease(stackKey);                                                                                            \
  JSStringRelease(messageStr);                                                                                          \
  JSStringRelease(stackStr);
