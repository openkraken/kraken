#define KRAKEN_EXPORT __attribute__((__visibility__("default")))

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


#define OBJECT_PROPERTY(name, ...)                                                                                     \
  name {                                                                                                               \
    __VA_ARGS__                                                                                                        \
  }
#define OBJECT_PROPERTY_ITEM(NAME, KEY)                                                                                \
  { #KEY, NAME##Property::KEY }
#define OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, KEY)                                                                         \
  { #KEY, NAME##PrototypeProperty::KEY }

#define OBJECT_PROTOTYPE_PROPERTY_ITEM_1(NAME, _1) OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _1)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_2(NAME, _1, _2)                                                                    \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_1(NAME, _1), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _2)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_3(NAME, _1, _2, _3)                                                                \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_2(NAME, _1, _2), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _3)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_4(NAME, _1, _2, _3, _4)                                                            \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_3(NAME, _1, _2, _3), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _4)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_5(NAME, _1, _2, _3, _4, _5)                                                        \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_4(NAME, _1, _2, _3, _4), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _5)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_6(NAME, _1, _2, _3, _4, _5, _6)                                                    \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_5(NAME, _1, _2, _3, _4, _5), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _6)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_7(NAME, _1, _2, _3, _4, _5, _6, _7)                                                \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_6(NAME, _1, _2, _3, _4, _5, _6), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _7)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_8(NAME, _1, _2, _3, _4, _5, _6, _7, _8)                                            \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_7(NAME, _1, _2, _3, _4, _5, _6, _7), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _8)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_9(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9)                                        \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_8(NAME, _1, _2, _3, _4, _5, _6, _7, _8), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _9)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_10(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10)                                  \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_9(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _10)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_11(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11)                             \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_10(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10), OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _11)
#define OBJECT_PROTOTYPE_PROPERTY_ITEM_12(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)                        \
  OBJECT_PROTOTYPE_PROPERTY_ITEM_11(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11),                                  \
    OBJECT_PROTOTYPE_PROPERTY_ITEM(NAME, _12)

#define OBJECT_PROPERTY_ITEM_1(NAME, _1) OBJECT_PROPERTY_ITEM(NAME, _1),
#define OBJECT_PROPERTY_ITEM_2(NAME, _1, _2) OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2),
#define OBJECT_PROPERTY_ITEM_3(NAME, _1, _2, _3)                                                                       \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),
#define OBJECT_PROPERTY_ITEM_4(NAME, _1, _2, _3, _4)                                                                   \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4),
#define OBJECT_PROPERTY_ITEM_5(NAME, _1, _2, _3, _4, _5)                                                               \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5),
#define OBJECT_PROPERTY_ITEM_6(NAME, _1, _2, _3, _4, _5, _6)                                                           \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),
#define OBJECT_PROPERTY_ITEM_7(NAME, _1, _2, _3, _4, _5, _6, _7)                                                       \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7),
#define OBJECT_PROPERTY_ITEM_8(NAME, _1, _2, _3, _4, _5, _6, _7, _8)                                                   \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8),
#define OBJECT_PROPERTY_ITEM_9(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9)                                               \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),
#define OBJECT_PROPERTY_ITEM_10(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10)                                         \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10),
#define OBJECT_PROPERTY_ITEM_11(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11)                                    \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11),
#define OBJECT_PROPERTY_ITEM_12(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)                               \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),
#define OBJECT_PROPERTY_ITEM_13(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13)                          \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13),
#define OBJECT_PROPERTY_ITEM_14(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)                     \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14),
#define OBJECT_PROPERTY_ITEM_15(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)                \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),
#define OBJECT_PROPERTY_ITEM_16(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)           \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16),
#define OBJECT_PROPERTY_ITEM_17(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)      \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17),
#define OBJECT_PROPERTY_ITEM_18(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18) \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),
#define OBJECT_PROPERTY_ITEM_19(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19)                                                                                   \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19),
#define OBJECT_PROPERTY_ITEM_20(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20)                                                                              \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20),
#define OBJECT_PROPERTY_ITEM_21(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21)                                                                         \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),
#define OBJECT_PROPERTY_ITEM_22(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22)                                                                    \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22),
#define OBJECT_PROPERTY_ITEM_23(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23)                                                               \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23),
#define OBJECT_PROPERTY_ITEM_24(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24)                                                          \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),
#define OBJECT_PROPERTY_ITEM_25(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25)                                                     \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25),
#define OBJECT_PROPERTY_ITEM_26(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26)                                                \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26),
#define OBJECT_PROPERTY_ITEM_27(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27)                                           \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),
#define OBJECT_PROPERTY_ITEM_28(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28)                                      \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28),
#define OBJECT_PROPERTY_ITEM_29(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29)                                 \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29),
#define OBJECT_PROPERTY_ITEM_30(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30)                            \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),
#define OBJECT_PROPERTY_ITEM_31(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31)                       \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31),
#define OBJECT_PROPERTY_ITEM_32(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32)                  \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32),
#define OBJECT_PROPERTY_ITEM_33(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33)             \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),
#define OBJECT_PROPERTY_ITEM_34(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34)        \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34),
#define OBJECT_PROPERTY_ITEM_35(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35)   \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35),
#define OBJECT_PROPERTY_ITEM_36(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36)                                                                                   \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),
#define OBJECT_PROPERTY_ITEM_37(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37)                                                                              \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37),
#define OBJECT_PROPERTY_ITEM_38(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38)                                                                         \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38),
#define OBJECT_PROPERTY_ITEM_39(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39)                                                                    \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),
#define OBJECT_PROPERTY_ITEM_40(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40)                                                               \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40),
#define OBJECT_PROPERTY_ITEM_41(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41)                                                          \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41),
#define OBJECT_PROPERTY_ITEM_42(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41, _42)                                                     \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41), OBJECT_PROPERTY_ITEM(NAME, _42),
#define OBJECT_PROPERTY_ITEM_43(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41, _42, _43)                                                \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41), OBJECT_PROPERTY_ITEM(NAME, _42),                 \
    OBJECT_PROPERTY_ITEM(NAME, _43),
#define OBJECT_PROPERTY_ITEM_44(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41, _42, _43, _44)                                           \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41), OBJECT_PROPERTY_ITEM(NAME, _42),                 \
    OBJECT_PROPERTY_ITEM(NAME, _43), OBJECT_PROPERTY_ITEM(NAME, _44),
#define OBJECT_PROPERTY_ITEM_45(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41, _42, _43, _44, _45)                                      \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41), OBJECT_PROPERTY_ITEM(NAME, _42),                 \
    OBJECT_PROPERTY_ITEM(NAME, _43), OBJECT_PROPERTY_ITEM(NAME, _44), OBJECT_PROPERTY_ITEM(NAME, _45),
#define OBJECT_PROPERTY_ITEM_46(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41, _42, _43, _44, _45, _46)                                 \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41), OBJECT_PROPERTY_ITEM(NAME, _42),                 \
    OBJECT_PROPERTY_ITEM(NAME, _43), OBJECT_PROPERTY_ITEM(NAME, _44), OBJECT_PROPERTY_ITEM(NAME, _45),                 \
    OBJECT_PROPERTY_ITEM(NAME, _46),
#define OBJECT_PROPERTY_ITEM_47(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41, _42, _43, _44, _45, _46, _47)                            \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41), OBJECT_PROPERTY_ITEM(NAME, _42),                 \
    OBJECT_PROPERTY_ITEM(NAME, _43), OBJECT_PROPERTY_ITEM(NAME, _44), OBJECT_PROPERTY_ITEM(NAME, _45),                 \
    OBJECT_PROPERTY_ITEM(NAME, _46), OBJECT_PROPERTY_ITEM(NAME, _47),
#define OBJECT_PROPERTY_ITEM_48(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41, _42, _43, _44, _45, _46, _47, _48)                       \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41), OBJECT_PROPERTY_ITEM(NAME, _42),                 \
    OBJECT_PROPERTY_ITEM(NAME, _43), OBJECT_PROPERTY_ITEM(NAME, _44), OBJECT_PROPERTY_ITEM(NAME, _45),                 \
    OBJECT_PROPERTY_ITEM(NAME, _46), OBJECT_PROPERTY_ITEM(NAME, _47), OBJECT_PROPERTY_ITEM(NAME, _48),
#define OBJECT_PROPERTY_ITEM_49(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41, _42, _43, _44, _45, _46, _47, _48, _49)                  \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41), OBJECT_PROPERTY_ITEM(NAME, _42),                 \
    OBJECT_PROPERTY_ITEM(NAME, _43), OBJECT_PROPERTY_ITEM(NAME, _44), OBJECT_PROPERTY_ITEM(NAME, _45),                 \
    OBJECT_PROPERTY_ITEM(NAME, _46), OBJECT_PROPERTY_ITEM(NAME, _47), OBJECT_PROPERTY_ITEM(NAME, _48),                 \
    OBJECT_PROPERTY_ITEM(NAME, _49),
#define OBJECT_PROPERTY_ITEM_50(NAME, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35,   \
                                _36, _37, _38, _39, _40, _41, _42, _43, _44, _45, _46, _47, _48, _49, _50)             \
  OBJECT_PROPERTY_ITEM(NAME, _1), OBJECT_PROPERTY_ITEM(NAME, _2), OBJECT_PROPERTY_ITEM(NAME, _3),                      \
    OBJECT_PROPERTY_ITEM(NAME, _4), OBJECT_PROPERTY_ITEM(NAME, _5), OBJECT_PROPERTY_ITEM(NAME, _6),                    \
    OBJECT_PROPERTY_ITEM(NAME, _7), OBJECT_PROPERTY_ITEM(NAME, _8), OBJECT_PROPERTY_ITEM(NAME, _9),                    \
    OBJECT_PROPERTY_ITEM(NAME, _10), OBJECT_PROPERTY_ITEM(NAME, _11), OBJECT_PROPERTY_ITEM(NAME, _12),                 \
    OBJECT_PROPERTY_ITEM(NAME, _13), OBJECT_PROPERTY_ITEM(NAME, _14), OBJECT_PROPERTY_ITEM(NAME, _15),                 \
    OBJECT_PROPERTY_ITEM(NAME, _16), OBJECT_PROPERTY_ITEM(NAME, _17), OBJECT_PROPERTY_ITEM(NAME, _18),                 \
    OBJECT_PROPERTY_ITEM(NAME, _19), OBJECT_PROPERTY_ITEM(NAME, _20), OBJECT_PROPERTY_ITEM(NAME, _21),                 \
    OBJECT_PROPERTY_ITEM(NAME, _22), OBJECT_PROPERTY_ITEM(NAME, _23), OBJECT_PROPERTY_ITEM(NAME, _24),                 \
    OBJECT_PROPERTY_ITEM(NAME, _25), OBJECT_PROPERTY_ITEM(NAME, _26), OBJECT_PROPERTY_ITEM(NAME, _27),                 \
    OBJECT_PROPERTY_ITEM(NAME, _28), OBJECT_PROPERTY_ITEM(NAME, _29), OBJECT_PROPERTY_ITEM(NAME, _30),                 \
    OBJECT_PROPERTY_ITEM(NAME, _31), OBJECT_PROPERTY_ITEM(NAME, _32), OBJECT_PROPERTY_ITEM(NAME, _33),                 \
    OBJECT_PROPERTY_ITEM(NAME, _34), OBJECT_PROPERTY_ITEM(NAME, _35), OBJECT_PROPERTY_ITEM(NAME, _36),                 \
    OBJECT_PROPERTY_ITEM(NAME, _37), OBJECT_PROPERTY_ITEM(NAME, _38), OBJECT_PROPERTY_ITEM(NAME, _39),                 \
    OBJECT_PROPERTY_ITEM(NAME, _40), OBJECT_PROPERTY_ITEM(NAME, _41), OBJECT_PROPERTY_ITEM(NAME, _42),                 \
    OBJECT_PROPERTY_ITEM(NAME, _43), OBJECT_PROPERTY_ITEM(NAME, _44), OBJECT_PROPERTY_ITEM(NAME, _45),                 \
    OBJECT_PROPERTY_ITEM(NAME, _46), OBJECT_PROPERTY_ITEM(NAME, _47), OBJECT_PROPERTY_ITEM(NAME, _48),                 \
    OBJECT_PROPERTY_ITEM(NAME, _49), OBJECT_PROPERTY_ITEM(NAME, _50),

#define OBJECT_PROPERTY_MAP_FUNCTION(NAME, ARGS_COUNT, ...)                                                            \
  static std::unordered_map<std::string, NAME##Property> &get##NAME##PropertyMap() {                                   \
    static std::unordered_map<std::string, NAME##Property> propertyMap{                                                \
      OBJECT_PROPERTY_ITEM_##ARGS_COUNT(NAME, __VA_ARGS__)};                                                           \
    return propertyMap;                                                                                                \
  };

#define OBJECT_PROTOTYPE_PROPERTY_MAP_FUNCTION(NAME, ARGS_COUNT, ...)                                                     \
  static std::unordered_map<std::string, NAME##PrototypeProperty> &get##NAME##PrototypePropertyMap() {                       \
    static std::unordered_map<std::string, NAME##PrototypeProperty> prototypePropertyMap{                                    \
      OBJECT_PROTOTYPE_PROPERTY_ITEM_##ARGS_COUNT(NAME, __VA_ARGS__)};                                                    \
    return prototypePropertyMap;                                                                                          \
  };

#define OBJECT_PROPERTY_NAME(KEY) JSStringCreateWithUTF8CString(#KEY)

#define OBJECT_PROPERTY_NAME_1(_1) OBJECT_PROPERTY_NAME(_1),
#define OBJECT_PROPERTY_NAME_2(_1, _2) OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2),
#define OBJECT_PROPERTY_NAME_3(_1, _2, _3) OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3),
#define OBJECT_PROPERTY_NAME_4(_1, _2, _3, _4)                                                                         \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),
#define OBJECT_PROPERTY_NAME_5(_1, _2, _3, _4, _5)                                                                     \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5),
#define OBJECT_PROPERTY_NAME_6(_1, _2, _3, _4, _5, _6)                                                                 \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6),
#define OBJECT_PROPERTY_NAME_7(_1, _2, _3, _4, _5, _6, _7)                                                             \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7),
#define OBJECT_PROPERTY_NAME_8(_1, _2, _3, _4, _5, _6, _7, _8)                                                         \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),
#define OBJECT_PROPERTY_NAME_9(_1, _2, _3, _4, _5, _6, _7, _8, _9)                                                     \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9),
#define OBJECT_PROPERTY_NAME_10(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10)                                               \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10),
#define OBJECT_PROPERTY_NAME_11(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11)                                          \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11),
#define OBJECT_PROPERTY_NAME_12(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)                                     \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),
#define OBJECT_PROPERTY_NAME_13(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13)                                \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13),
#define OBJECT_PROPERTY_NAME_14(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)                           \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14),
#define OBJECT_PROPERTY_NAME_15(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)                      \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15),
#define OBJECT_PROPERTY_NAME_16(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)                 \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),
#define OBJECT_PROPERTY_NAME_17(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)            \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17),
#define OBJECT_PROPERTY_NAME_18(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18)       \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18),
#define OBJECT_PROPERTY_NAME_19(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19)  \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19),
#define OBJECT_PROPERTY_NAME_20(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20)                                                                                   \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),
#define OBJECT_PROPERTY_NAME_21(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21)                                                                              \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21),
#define OBJECT_PROPERTY_NAME_22(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22)                                                                         \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22),
#define OBJECT_PROPERTY_NAME_23(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23)                                                                    \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23),
#define OBJECT_PROPERTY_NAME_24(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24)                                                               \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),
#define OBJECT_PROPERTY_NAME_25(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25)                                                          \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25),
#define OBJECT_PROPERTY_NAME_26(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26)                                                     \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26),
#define OBJECT_PROPERTY_NAME_27(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27)                                                \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27),
#define OBJECT_PROPERTY_NAME_28(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28)                                           \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),
#define OBJECT_PROPERTY_NAME_29(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29)                                      \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29),
#define OBJECT_PROPERTY_NAME_30(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30)                                 \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30),
#define OBJECT_PROPERTY_NAME_31(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31)                            \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31),
#define OBJECT_PROPERTY_NAME_32(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32)                       \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),
#define OBJECT_PROPERTY_NAME_33(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33)                  \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33),
#define OBJECT_PROPERTY_NAME_34(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34)             \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34),
#define OBJECT_PROPERTY_NAME_35(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35)        \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35),
#define OBJECT_PROPERTY_NAME_36(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36)   \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),
#define OBJECT_PROPERTY_NAME_37(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37)                                                                                   \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37),
#define OBJECT_PROPERTY_NAME_38(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38)                                                                              \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38),
#define OBJECT_PROPERTY_NAME_39(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39)                                                                         \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39),
#define OBJECT_PROPERTY_NAME_40(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40)                                                                    \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),
#define OBJECT_PROPERTY_NAME_41(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41)                                                               \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41),
#define OBJECT_PROPERTY_NAME_42(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41, _42)                                                          \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41), OBJECT_PROPERTY_NAME(_42),
#define OBJECT_PROPERTY_NAME_43(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41, _42, _43)                                                     \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41), OBJECT_PROPERTY_NAME(_42), OBJECT_PROPERTY_NAME(_43),
#define OBJECT_PROPERTY_NAME_44(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41, _42, _43, _44)                                                \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41), OBJECT_PROPERTY_NAME(_42), OBJECT_PROPERTY_NAME(_43), OBJECT_PROPERTY_NAME(_44),
#define OBJECT_PROPERTY_NAME_45(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41, _42, _43, _44, _45)                                           \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41), OBJECT_PROPERTY_NAME(_42), OBJECT_PROPERTY_NAME(_43), OBJECT_PROPERTY_NAME(_44),        \
    OBJECT_PROPERTY_NAME(_45),
#define OBJECT_PROPERTY_NAME_46(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41, _42, _43, _44, _45, _46)                                      \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41), OBJECT_PROPERTY_NAME(_42), OBJECT_PROPERTY_NAME(_43), OBJECT_PROPERTY_NAME(_44),        \
    OBJECT_PROPERTY_NAME(_45), OBJECT_PROPERTY_NAME(_46),
#define OBJECT_PROPERTY_NAME_47(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41, _42, _43, _44, _45, _46, _47)                                 \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41), OBJECT_PROPERTY_NAME(_42), OBJECT_PROPERTY_NAME(_43), OBJECT_PROPERTY_NAME(_44),        \
    OBJECT_PROPERTY_NAME(_45), OBJECT_PROPERTY_NAME(_46), OBJECT_PROPERTY_NAME(_47),
#define OBJECT_PROPERTY_NAME_48(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41, _42, _43, _44, _45, _46, _47, _48)                            \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41), OBJECT_PROPERTY_NAME(_42), OBJECT_PROPERTY_NAME(_43), OBJECT_PROPERTY_NAME(_44),        \
    OBJECT_PROPERTY_NAME(_45), OBJECT_PROPERTY_NAME(_46), OBJECT_PROPERTY_NAME(_47), OBJECT_PROPERTY_NAME(_48),
#define OBJECT_PROPERTY_NAME_49(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41, _42, _43, _44, _45, _46, _47, _48, _49)                       \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41), OBJECT_PROPERTY_NAME(_42), OBJECT_PROPERTY_NAME(_43), OBJECT_PROPERTY_NAME(_44),        \
    OBJECT_PROPERTY_NAME(_45), OBJECT_PROPERTY_NAME(_46), OBJECT_PROPERTY_NAME(_47), OBJECT_PROPERTY_NAME(_48),        \
    OBJECT_PROPERTY_NAME(_49),
#define OBJECT_PROPERTY_NAME_50(_1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,  \
                                _20, _21, _22, _23, _24, _25, _26, _27, _28, _29, _30, _31, _32, _33, _34, _35, _36,   \
                                _37, _38, _39, _40, _41, _42, _43, _44, _45, _46, _47, _48, _49, _50)                  \
  OBJECT_PROPERTY_NAME(_1), OBJECT_PROPERTY_NAME(_2), OBJECT_PROPERTY_NAME(_3), OBJECT_PROPERTY_NAME(_4),              \
    OBJECT_PROPERTY_NAME(_5), OBJECT_PROPERTY_NAME(_6), OBJECT_PROPERTY_NAME(_7), OBJECT_PROPERTY_NAME(_8),            \
    OBJECT_PROPERTY_NAME(_9), OBJECT_PROPERTY_NAME(_10), OBJECT_PROPERTY_NAME(_11), OBJECT_PROPERTY_NAME(_12),         \
    OBJECT_PROPERTY_NAME(_13), OBJECT_PROPERTY_NAME(_14), OBJECT_PROPERTY_NAME(_15), OBJECT_PROPERTY_NAME(_16),        \
    OBJECT_PROPERTY_NAME(_17), OBJECT_PROPERTY_NAME(_18), OBJECT_PROPERTY_NAME(_19), OBJECT_PROPERTY_NAME(_20),        \
    OBJECT_PROPERTY_NAME(_21), OBJECT_PROPERTY_NAME(_22), OBJECT_PROPERTY_NAME(_23), OBJECT_PROPERTY_NAME(_24),        \
    OBJECT_PROPERTY_NAME(_25), OBJECT_PROPERTY_NAME(_26), OBJECT_PROPERTY_NAME(_27), OBJECT_PROPERTY_NAME(_28),        \
    OBJECT_PROPERTY_NAME(_29), OBJECT_PROPERTY_NAME(_30), OBJECT_PROPERTY_NAME(_31), OBJECT_PROPERTY_NAME(_32),        \
    OBJECT_PROPERTY_NAME(_33), OBJECT_PROPERTY_NAME(_34), OBJECT_PROPERTY_NAME(_35), OBJECT_PROPERTY_NAME(_36),        \
    OBJECT_PROPERTY_NAME(_37), OBJECT_PROPERTY_NAME(_38), OBJECT_PROPERTY_NAME(_39), OBJECT_PROPERTY_NAME(_40),        \
    OBJECT_PROPERTY_NAME(_41), OBJECT_PROPERTY_NAME(_42), OBJECT_PROPERTY_NAME(_43), OBJECT_PROPERTY_NAME(_44),        \
    OBJECT_PROPERTY_NAME(_45), OBJECT_PROPERTY_NAME(_46), OBJECT_PROPERTY_NAME(_47), OBJECT_PROPERTY_NAME(_48),        \
    OBJECT_PROPERTY_NAME(_49), OBJECT_PROPERTY_NAME(_50),

#define OBJECT_PROPERTY_NAME_FUNCTION(NAME, ARGS_COUNT, ...)                                                           \
  static std::vector<JSStringRef> &get##NAME##PropertyNames() {                                                        \
    static std::vector<JSStringRef> propertyNames{OBJECT_PROPERTY_NAME_##ARGS_COUNT(__VA_ARGS__)};                     \
    return propertyNames;                                                                                              \
  }

#define OBJECT_PROTOTYPE_PROPERTY_NAME_FUNCTION(NAME, ARGS_COUNT, ...)                                                    \
  static std::vector<JSStringRef> &get##NAME##PrototypePropertyNames() {                                                  \
    static std::vector<JSStringRef> propertyNames{OBJECT_PROPERTY_NAME_##ARGS_COUNT(__VA_ARGS__)};                     \
    return propertyNames;                                                                                              \
  }

#define DEFINE_OBJECT_PROPERTY(NAME, ARGS_COUNT, ...)                                                                  \
  enum class OBJECT_PROPERTY(NAME##Property, __VA_ARGS__);                                                             \
  OBJECT_PROPERTY_MAP_FUNCTION(NAME, ARGS_COUNT, __VA_ARGS__);                                                         \
  OBJECT_PROPERTY_NAME_FUNCTION(NAME, ARGS_COUNT, __VA_ARGS__)

#define DEFINE_PROTOTYPE_OBJECT_PROPERTY(NAME, ARGS_COUNT, ...)                                                           \
  enum class OBJECT_PROPERTY(NAME##PrototypeProperty, __VA_ARGS__);                                                    \
  OBJECT_PROTOTYPE_PROPERTY_MAP_FUNCTION(NAME, ARGS_COUNT, __VA_ARGS__)                                                \
  OBJECT_PROTOTYPE_PROPERTY_NAME_FUNCTION(NAME, ARGS_COUNT, __VA_ARGS__)
