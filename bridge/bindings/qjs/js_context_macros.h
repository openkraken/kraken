/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_MACROS_H
#define KRAKENBRIDGE_JS_CONTEXT_MACROS_H

#define OBJECT_INSTANCE(NAME)                                                                                          \
  static std::unordered_map<JSContext *, NAME*> m_instanceMap;                                                       \
  static NAME *instance(JSContext *context) {                                                                          \
    if (m_instanceMap.count(context) == 0) {                                                                           \
      m_instanceMap[context] = new NAME(context);                                                                      \
    }                                                                                                                  \
    return m_instanceMap[context];                                                                                     \
  }

#define OBJECT_INSTANCE_IMPL(NAME) std::unordered_map<JSContext *, NAME*> NAME::m_instanceMap{}

#define QJS_GLOBAL_BINDING_FUNCTION(context, function, name, argc)                                                     \
  {                                                                                                                    \
    JSValue f = JS_NewCFunction(context->ctx(), function, name, argc);                                                 \
    context->defineGlobalProperty(name, f);                                                                            \
  }

#define PROP_GETTER(Constructor, Property) JSValue Constructor::Property##PropertyDescriptor::getter
#define PROP_SETTER(Constructor, Property) JSValue Constructor::Property##PropertyDescriptor::setter

#define OBJECT_PROPERTY_ITEM(NAME)                                                                                     \
  class NAME##PropertyDescriptor {                                                                                     \
  public:                                                                                                              \
    static JSValue getter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);                       \
    static JSValue setter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);                       \
  };                                                                                                                   \
  ObjectProperty m_##NAME{m_context, m_prototypeObject, #NAME, NAME##PropertyDescriptor::getter,                      \
                          NAME##PropertyDescriptor::setter};

#define OBJECT_PROPERTY_ITEM_1(_0) OBJECT_PROPERTY_ITEM(_0)
#define OBJECT_PROPERTY_ITEM_2(_0, _1) OBJECT_PROPERTY_ITEM_1(_0) OBJECT_PROPERTY_ITEM(_1)
#define OBJECT_PROPERTY_ITEM_3(_0, _1, _2) OBJECT_PROPERTY_ITEM_2(_0, _1) OBJECT_PROPERTY_ITEM(_2)
#define OBJECT_PROPERTY_ITEM_4(_0, _1, _2, _3) OBJECT_PROPERTY_ITEM_3(_0, _1, _2) OBJECT_PROPERTY_ITEM(_3)
#define OBJECT_PROPERTY_ITEM_5(_0, _1, _2, _3, _4) OBJECT_PROPERTY_ITEM_4(_0, _1, _2, _3) OBJECT_PROPERTY_ITEM(_4)
#define OBJECT_PROPERTY_ITEM_6(_0, _1, _2, _3, _4, _5)                                                                 \
  OBJECT_PROPERTY_ITEM_5(_0, _1, _2, _3, _4) OBJECT_PROPERTY_ITEM(_5)
#define OBJECT_PROPERTY_ITEM_7(_0, _1, _2, _3, _4, _5, _6)                                                             \
  OBJECT_PROPERTY_ITEM_6(_0, _1, _2, _3, _4, _5) OBJECT_PROPERTY_ITEM(_6)
#define OBJECT_PROPERTY_ITEM_8(_0, _1, _2, _3, _4, _5, _6, _7)                                                         \
  OBJECT_PROPERTY_ITEM_7(_0, _1, _2, _3, _4, _5, _6) OBJECT_PROPERTY_ITEM(_7)
#define OBJECT_PROPERTY_ITEM_9(_0, _1, _2, _3, _4, _5, _6, _7, _8)                                                     \
  OBJECT_PROPERTY_ITEM_8(_0, _1, _2, _3, _4, _5, _6, _7) OBJECT_PROPERTY_ITEM(_8)
#define OBJECT_PROPERTY_ITEM_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9)                                                \
  OBJECT_PROPERTY_ITEM_9(_0, _1, _2, _3, _4, _5, _6, _7, _8) OBJECT_PROPERTY_ITEM(_9)
#define OBJECT_PROPERTY_ITEM_11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10)                                           \
  OBJECT_PROPERTY_ITEM_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9) OBJECT_PROPERTY_ITEM(_10)
#define OBJECT_PROPERTY_ITEM_12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11)                                      \
  OBJECT_PROPERTY_ITEM_11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) OBJECT_PROPERTY_ITEM(_11)
#define OBJECT_PROPERTY_ITEM_13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)                                 \
  OBJECT_PROPERTY_ITEM_12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) OBJECT_PROPERTY_ITEM(_12)
#define OBJECT_PROPERTY_ITEM_14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13)                            \
  OBJECT_PROPERTY_ITEM_13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) OBJECT_PROPERTY_ITEM(_13)
#define OBJECT_PROPERTY_ITEM_15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)                       \
  OBJECT_PROPERTY_ITEM_14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) OBJECT_PROPERTY_ITEM(_14)
#define OBJECT_PROPERTY_ITEM_16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)                  \
  OBJECT_PROPERTY_ITEM_15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14) OBJECT_PROPERTY_ITEM(_15)
#define OBJECT_PROPERTY_ITEM_17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)             \
  OBJECT_PROPERTY_ITEM_16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)                        \
  OBJECT_PROPERTY_ITEM(_16)
#define OBJECT_PROPERTY_ITEM_18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)        \
  OBJECT_PROPERTY_ITEM_17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)                   \
  OBJECT_PROPERTY_ITEM(_17)
#define OBJECT_PROPERTY_ITEM_19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18)   \
  OBJECT_PROPERTY_ITEM_18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)              \
  OBJECT_PROPERTY_ITEM(_18)
#define OBJECT_PROPERTY_ITEM_20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19)                                                                                   \
  OBJECT_PROPERTY_ITEM_19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18)         \
  OBJECT_PROPERTY_ITEM(_19)
#define OBJECT_PROPERTY_ITEM_21(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19, _20)                                                                              \
  OBJECT_PROPERTY_ITEM_20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19)    \
  OBJECT_PROPERTY_ITEM(_20)
#define OBJECT_PROPERTY_ITEM_22(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19, _20, _21)                                                                         \
  OBJECT_PROPERTY_ITEM_21(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,    \
                          _20)                                                                                         \
  OBJECT_PROPERTY_ITEM(_21)
#define OBJECT_PROPERTY_ITEM_23(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19, _20, _21, _22)                                                                    \
  OBJECT_PROPERTY_ITEM_22(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,    \
                          _20, _21)                                                                                    \
  OBJECT_PROPERTY_ITEM(_22)
#define OBJECT_PROPERTY_ITEM_24(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19, _20, _21, _22, _23)                                                               \
  OBJECT_PROPERTY_ITEM_23(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,    \
                          _20, _21, _22)                                                                               \
  OBJECT_PROPERTY_ITEM(_23)
#define OBJECT_PROPERTY_ITEM_25(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19, _20, _21, _22, _23, _24)                                                          \
  OBJECT_PROPERTY_ITEM_24(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,    \
                          _20, _21, _22, _23)                                                                          \
  OBJECT_PROPERTY_ITEM(_24)
#define OBJECT_PROPERTY_ITEM_26(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19, _20, _21, _22, _23, _24, _25)                                                     \
  OBJECT_PROPERTY_ITEM_25(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,    \
                          _20, _21, _22, _23, _24)                                                                     \
  OBJECT_PROPERTY_ITEM(_25)
#define OBJECT_PROPERTY_ITEM_27(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19, _20, _21, _22, _23, _24, _25, _26)                                                \
  OBJECT_PROPERTY_ITEM_26(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,    \
                          _20, _21, _22, _23, _24, _25)                                                                \
  OBJECT_PROPERTY_ITEM(_26)
#define OBJECT_PROPERTY_ITEM_28(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27)                                           \
  OBJECT_PROPERTY_ITEM_27(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,    \
                          _20, _21, _22, _23, _24, _25, _26)                                                           \
  OBJECT_PROPERTY_ITEM(_27)
#define OBJECT_PROPERTY_ITEM_29(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,   \
                                _19, _20, _21, _22, _23, _24, _25, _26, _27, _28)                                      \
  OBJECT_PROPERTY_ITEM_28(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19,    \
                          _20, _21, _22, _23, _24, _25, _26, _27)                                                      \
  OBJECT_PROPERTY_ITEM(_28)

#define DEFINE_OBJECT_PROPERTY(ARGS_COUNT, ...) OBJECT_PROPERTY_ITEM_##ARGS_COUNT(__VA_ARGS__)

#endif // KRAKENBRIDGE_JS_CONTEXT_MACROS_H
