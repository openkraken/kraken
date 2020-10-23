#define KRAKEN_BINDING_CONSOLE "__kraken_print__"

#define JSC_GLOBAL_BINDING_FUNCTION(context, nameStr, func)                                                            \
  {                                                                                                                    \
    JSClassDefinition functionDefinition = kJSClassDefinitionEmpty;                                                    \
    functionDefinition.className = nameStr;                                                                            \
    functionDefinition.callAsFunction = func;                                                                          \
    functionDefinition.version = 0;                                                                                    \
    JSClassRef functionClass = JSClassCreate(&functionDefinition);                                                     \
    JSObjectRef function = JSObjectMake(context->context(), functionClass, context.get());                             \
    JSStringRef name = JSStringCreateWithUTF8CString(nameStr);                                                         \
    context->emplaceGlobalString(name);                                                                                \
    JSValueRef exc = nullptr;                                                                                          \
    JSObjectSetProperty(context->context(), context->global(), name, function, kJSPropertyAttributeNone, &exc);        \
    context->handleException(exc);                                                                                     \
  }

#define JSC_GLOBAL_BINDING_HOST_OBJECT(context, nameStr, hostObject)                                                   \
  {                                                                                                                    \
    JSClassRef objectClass = hostObject->object;                                                                       \
    JSObjectRef object = JSObjectMake(context->context(), objectClass, hostObject);                                    \
    JSStringRef name = JSStringCreateWithUTF8CString(nameStr);                                                         \
    context->emplaceGlobalString(name);                                                                                \
    JSObjectSetProperty(context->context(), context->global(), name, object, kJSPropertyAttributeReadOnly, nullptr);   \
  }

#define JSC_SET_STRING_PROPERTY(context, object, name, value)                                                          \
  {                                                                                                                    \
    JSStringRef keyRef = JSStringCreateWithUTF8CString(name);                                                          \
    JSStringRef valueStringRef = JSStringCreateWithUTF8CString(value);                                                 \
    JSValueRef valueRef = JSValueMakeString(context->context(), valueStringRef);                                       \
    JSObjectSetProperty(context->context(), object, keyRef, valueRef, kJSPropertyAttributeNone, nullptr);              \
    JSStringRelease(keyRef);                                                                                           \
  }

#define JSC_GLOBAL_SET_PROPERTY(context, key, value)                                                                   \
  {                                                                                                                    \
    JSStringRef keyString = JSStringCreateWithUTF8CString(key);                                                        \
    context->emplaceGlobalString(keyString);                                                                           \
    JSObjectSetProperty(context->context(), context->global(), keyString, value, kJSPropertyAttributeReadOnly,         \
                        nullptr);                                                                                      \
  }

#define HANDLE_JSC_EXCEPTION(ctx_, exc, handler)                                                                       \
  {                                                                                                                    \
    JSObjectRef error = JSValueToObject(ctx_, exc, nullptr);                                                           \
    JSStringRef messageKey = JSStringCreateWithUTF8CString("message");                                                 \
    JSStringRef stackKey = JSStringCreateWithUTF8CString("stack");                                                     \
    JSValueRef messageRef = JSObjectGetProperty(ctx_, error, messageKey, nullptr);                                     \
    JSValueRef stackRef = JSObjectGetProperty(ctx_, error, stackKey, nullptr);                                         \
    JSStringRef messageStr = JSValueToStringCopy(ctx_, messageRef, nullptr);                                           \
    JSStringRef stackStr = JSValueToStringCopy(ctx_, stackRef, nullptr);                                               \
    std::string message = JSStringToStdString(messageStr);                                                             \
    std::string stack = JSStringToStdString(stackStr);                                                                 \
    handler(getContextId(), (message + '\n' + stack).c_str());                                                         \
    JSStringRelease(messageKey);                                                                                       \
    JSStringRelease(stackKey);                                                                                         \
    JSStringRelease(messageStr);                                                                                       \
    JSStringRelease(stackStr);                                                                                         \
  }

#define JSC_CREATE_CLASS_DEFINITION(definition, name, classObject)                                                     \
  {                                                                                                                    \
    definition.version = 0;                                                                                            \
    definition.className = name;                                                                                       \
    definition.attributes = kJSClassAttributeNoAutomaticPrototype;                                                     \
    definition.finalize = classObject::finalize;                                                                       \
    definition.getProperty = classObject::proxyGetProperty;                                                            \
    definition.setProperty = classObject::proxySetProperty;                                                            \
    definition.getPropertyNames = classObject::proxyGetPropertyNames;                                                  \
    definition.hasInstance = classObject::hasInstance;                                                                 \
  }

#define JSC_THROW_ERROR(ctx, msg, exception)                                                                           \
  {                                                                                                                    \
    JSStringRef _errmsg = JSStringCreateWithUTF8CString(msg);                                                          \
    const JSValueRef args[] = {JSValueMakeString(ctx, _errmsg), nullptr};                                              \
    *exception = JSObjectMakeError(ctx, 1, args, nullptr);                                                             \
    JSStringRelease(_errmsg);                                                                                          \
  }
