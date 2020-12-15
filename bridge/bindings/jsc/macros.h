#include "object_property_macros.h"

#define KRAKEN_BINDING_CONSOLE "__kraken_print__"

#define BODY_TARGET_ID -1
#define WINDOW_TARGET_ID -2
#define DOCUMENT_TARGET_ID -3

#define assert_m(exp, msg) assert(((void)msg, exp))

#define OBJECT_INSTANCE(NAME)                                                                                          \
  static NAME *instance(JSContext *context) {                                                                          \
    if (instanceMap.count(context) == 0) {                                                                             \
      instanceMap[context] = new NAME(context);                                                             \
    }                                                                                                                  \
    return instanceMap[context];                                                                                       \
  }

#define JSC_GLOBAL_BINDING_FUNCTION(context, nameStr, func)                                                            \
  {                                                                                                                    \
    JSClassDefinition functionDefinition = kJSClassDefinitionEmpty;                                                    \
    functionDefinition.className = nameStr;                                                                            \
    functionDefinition.callAsFunction = func;                                                                          \
    functionDefinition.version = 0;                                                                                    \
    JSClassRef functionClass = JSClassCreate(&functionDefinition);                                                     \
    JSObjectRef function = JSObjectMake(context->context(), functionClass, context.get());                             \
    JSValueProtect(context->context(), function);                                                                      \
    JSStringRef name = JSStringCreateWithUTF8CString(nameStr);                                                         \
    JSValueRef exc = nullptr;                                                                                          \
    JSObjectSetProperty(context->context(), context->global(), name, function, kJSPropertyAttributeNone, &exc);        \
    JSStringRelease(name);                                                                                             \
    context->handleException(exc);                                                                                     \
  }

#define JSC_GLOBAL_BINDING_HOST_OBJECT(context, nameStr, hostObject)                                                   \
  {                                                                                                                    \
    JSObjectRef object = hostObject->jsObject;                                                                         \
    JSValueProtect(context->context(), object);                                                                        \
    JSStringRef name = JSStringCreateWithUTF8CString(nameStr);                                                         \
    JSObjectSetProperty(context->context(), context->global(), name, object, kJSPropertyAttributeReadOnly, nullptr);   \
    JSStringRelease(name);                                                                                             \
  }

#define JSC_SET_STRING_PROPERTY(context, object, name, valueRef)                                                       \
  {                                                                                                                    \
    JSStringRef keyRef = JSStringCreateWithUTF8CString(name);                                                          \
    JSObjectSetProperty(context->context(), object, keyRef, valueRef, kJSPropertyAttributeNone, nullptr);              \
    JSStringRelease(keyRef);                                                                                           \
  }

#define JSC_GLOBAL_SET_PROPERTY(context, key, value)                                                                   \
  {                                                                                                                    \
    JSStringRef keyString = JSStringCreateWithUTF8CString(key);                                                        \
    JSObjectSetProperty(context->context(), context->global(), keyString, value, kJSPropertyAttributeReadOnly,         \
                        nullptr);                                                                                      \
    JSStringRelease(keyString);                                                                                        \
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
    std::string &&message = JSStringToStdString(messageStr);                                                           \
    std::string &&stack = JSStringToStdString(stackStr);                                                               \
    handler(getContextId(), (message + '\n' + stack).c_str());                                                         \
    JSStringRelease(messageKey);                                                                                       \
    JSStringRelease(stackKey);                                                                                         \
    JSStringRelease(messageStr);                                                                                       \
    JSStringRelease(stackStr);                                                                                         \
  }

#define JSC_CREATE_HOST_OBJECT_DEFINITION(definition, name, classObject)                                               \
  {                                                                                                                    \
    definition.version = 0;                                                                                            \
    definition.className = name;                                                                                       \
    definition.attributes = kJSClassAttributeNoAutomaticPrototype;                                                     \
    definition.finalize = classObject::proxyFinalize;                                                                  \
    definition.getProperty = classObject::proxyGetProperty;                                                            \
    definition.setProperty = classObject::proxySetProperty;                                                            \
    definition.getPropertyNames = classObject::proxyGetPropertyNames;                                                  \
  }

#define JSC_CREATE_HOST_CLASS_INSTANCE_DEFINITION(definition, name, classObject, staticFunction)                       \
  {                                                                                                                    \
    definition.version = 0;                                                                                            \
    definition.className = name;                                                                                       \
    definition.attributes = kJSClassAttributeNoAutomaticPrototype;                                                     \
    definition.finalize = classObject::proxyInstanceFinalize;                                                          \
    definition.staticFunctions = staticFunction;                                                                       \
    definition.getProperty = classObject::proxyInstanceGetProperty;                                                    \
    definition.setProperty = classObject::proxyInstanceSetProperty;                                                    \
    definition.getPropertyNames = classObject::proxyInstanceGetPropertyNames;                                          \
  }

#define JSC_CREATE_HOST_CLASS_DEFINITION(definition, parent, name, staticFunction, staticValue, HostClass)             \
  {                                                                                                                    \
    definition.version = 0;                                                                                            \
    definition.parentClass = parent;                                                                                   \
    definition.className = name;                                                                                       \
    definition.attributes = kJSClassAttributeNoAutomaticPrototype;                                                     \
    definition.staticFunctions = staticFunction;                                                                       \
    definition.staticValues = staticValue;                                                                             \
    definition.finalize = HostClass::proxyFinalize;                                                                    \
    definition.hasInstance = HostClass::proxyHasInstance;                                                              \
    definition.callAsConstructor = HostClass::proxyCallAsConstructor;                                                  \
    definition.callAsFunction = HostClass::proxyCallAsFunction;                                                        \
    definition.getProperty = HostClass::proxyGetProperty;                                                              \
  }

#define JSC_THROW_ERROR(ctx, msg, exception)                                                                           \
  {                                                                                                                    \
    JSStringRef _errmsg = JSStringCreateWithUTF8CString(msg);                                                          \
    const JSValueRef args[] = {JSValueMakeString(ctx, _errmsg), nullptr};                                              \
    *exception = JSObjectMakeError(ctx, 1, args, nullptr);                                                             \
    JSStringRelease(_errmsg);                                                                                          \
  }
