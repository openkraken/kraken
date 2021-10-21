/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_MACROS_H
#define KRAKENBRIDGE_JS_CONTEXT_MACROS_H

#define OBJECT_INSTANCE(NAME)                                                                                          \
  static NAME *instance(JSContext *context) {                                                                          \
     if (context->constructorMap.count(#NAME) == 0) {                                                                  \
        context->constructorMap[#NAME] = static_cast<void*>(new NAME(context));                                        \
     }                                                                                                                 \
     return static_cast<NAME *>(context->constructorMap[#NAME]);                                                       \
  }

#define QJS_GLOBAL_BINDING_FUNCTION(context, function, name, argc)                                                     \
  {                                                                                                                    \
    JSValue f = JS_NewCFunction(context->ctx(), function, name, argc);                                                 \
    context->defineGlobalProperty(name, f);                                                                            \
  }

#define PROP_GETTER(Constructor, Property) JSValue Constructor::Property##PropertyDescriptor::getter
#define PROP_SETTER(Constructor, Property) JSValue Constructor::Property##PropertyDescriptor::setter

#define HOST_CLASS_PROPERTY_ITEM(NAME)                                                                                 \
  class NAME##PropertyDescriptor {                                                                                     \
  public:                                                                                                              \
    static JSValue getter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);                       \
    static JSValue setter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);                       \
  };                                                                                                                   \
  ObjectProperty __##NAME{m_context, instanceObject, #NAME, NAME##PropertyDescriptor::getter,                       \
                          NAME##PropertyDescriptor::setter};

#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(NAME)                                                                                 \
  class NAME##PropertyDescriptor {                                                                                     \
  public:                                                                                                              \
    static JSValue getter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);                       \
    static JSValue setter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);                       \
  };                                                                                                                   \
  ObjectProperty __##NAME{m_context, m_prototypeObject, #NAME, NAME##PropertyDescriptor::getter,                       \
                          NAME##PropertyDescriptor::setter};

#define HOST_OBJECT_PROPERTY_ITEM(NAME)                                                                                \
  class NAME##PropertyDescriptor {                                                                                     \
  public:                                                                                                              \
    static JSValue getter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);                       \
    static JSValue setter(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);                       \
  };                                                                                                                   \
  ObjectProperty m_##NAME{m_context, jsObject, #NAME, NAME##PropertyDescriptor::getter,                                \
                          NAME##PropertyDescriptor::setter};

#define HOST_CLASS_PROPERTY_ITEM_1(_0) HOST_CLASS_PROPERTY_ITEM(_0)
#define HOST_CLASS_PROPERTY_ITEM_2(_0, _1) HOST_CLASS_PROPERTY_ITEM_1(_0) HOST_CLASS_PROPERTY_ITEM(_1)
#define HOST_CLASS_PROPERTY_ITEM_3(_0, _1, _2) HOST_CLASS_PROPERTY_ITEM_2(_0, _1) HOST_CLASS_PROPERTY_ITEM(_2)
#define HOST_CLASS_PROPERTY_ITEM_4(_0, _1, _2, _3) HOST_CLASS_PROPERTY_ITEM_3(_0, _1, _2) HOST_CLASS_PROPERTY_ITEM(_3)
#define HOST_CLASS_PROPERTY_ITEM_5(_0, _1, _2, _3, _4)                                                                 \
  HOST_CLASS_PROPERTY_ITEM_4(_0, _1, _2, _3) HOST_CLASS_PROPERTY_ITEM(_4)
#define HOST_CLASS_PROPERTY_ITEM_6(_0, _1, _2, _3, _4, _5)                                                             \
  HOST_CLASS_PROPERTY_ITEM_5(_0, _1, _2, _3, _4) HOST_CLASS_PROPERTY_ITEM(_5)
#define HOST_CLASS_PROPERTY_ITEM_7(_0, _1, _2, _3, _4, _5, _6)                                                         \
  HOST_CLASS_PROPERTY_ITEM_6(_0, _1, _2, _3, _4, _5) HOST_CLASS_PROPERTY_ITEM(_6)
#define HOST_CLASS_PROPERTY_ITEM_8(_0, _1, _2, _3, _4, _5, _6, _7)                                                     \
  HOST_CLASS_PROPERTY_ITEM_7(_0, _1, _2, _3, _4, _5, _6) HOST_CLASS_PROPERTY_ITEM(_7)
#define HOST_CLASS_PROPERTY_ITEM_9(_0, _1, _2, _3, _4, _5, _6, _7, _8)                                                 \
  HOST_CLASS_PROPERTY_ITEM_8(_0, _1, _2, _3, _4, _5, _6, _7) HOST_CLASS_PROPERTY_ITEM(_8)
#define HOST_CLASS_PROPERTY_ITEM_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9)                                            \
  HOST_CLASS_PROPERTY_ITEM_9(_0, _1, _2, _3, _4, _5, _6, _7, _8) HOST_CLASS_PROPERTY_ITEM(_9)
#define HOST_CLASS_PROPERTY_ITEM_11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10)                                       \
  HOST_CLASS_PROPERTY_ITEM_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9) HOST_CLASS_PROPERTY_ITEM(_10)
#define HOST_CLASS_PROPERTY_ITEM_12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11)                                  \
  HOST_CLASS_PROPERTY_ITEM_11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) HOST_CLASS_PROPERTY_ITEM(_11)
#define HOST_CLASS_PROPERTY_ITEM_13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)                             \
  HOST_CLASS_PROPERTY_ITEM_12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) HOST_CLASS_PROPERTY_ITEM(_12)
#define HOST_CLASS_PROPERTY_ITEM_14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13)                        \
  HOST_CLASS_PROPERTY_ITEM_13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) HOST_CLASS_PROPERTY_ITEM(_13)
#define HOST_CLASS_PROPERTY_ITEM_15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)                   \
  HOST_CLASS_PROPERTY_ITEM_14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) HOST_CLASS_PROPERTY_ITEM(_14)
#define HOST_CLASS_PROPERTY_ITEM_16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)              \
  HOST_CLASS_PROPERTY_ITEM_15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)                         \
  HOST_CLASS_PROPERTY_ITEM(_15)
#define HOST_CLASS_PROPERTY_ITEM_17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)         \
  HOST_CLASS_PROPERTY_ITEM_16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)                    \
  HOST_CLASS_PROPERTY_ITEM(_16)
#define HOST_CLASS_PROPERTY_ITEM_18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)    \
  HOST_CLASS_PROPERTY_ITEM_17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)               \
  HOST_CLASS_PROPERTY_ITEM(_17)
#define HOST_CLASS_PROPERTY_ITEM_19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18)                                                                               \
  HOST_CLASS_PROPERTY_ITEM_18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)          \
  HOST_CLASS_PROPERTY_ITEM(_18)
#define HOST_CLASS_PROPERTY_ITEM_20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19)                                                                          \
  HOST_CLASS_PROPERTY_ITEM_19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18)     \
  HOST_CLASS_PROPERTY_ITEM(_19)
#define HOST_CLASS_PROPERTY_ITEM_21(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20)                                                                     \
  HOST_CLASS_PROPERTY_ITEM_20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19)                                                                                     \
  HOST_CLASS_PROPERTY_ITEM(_20)
#define HOST_CLASS_PROPERTY_ITEM_22(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21)                                                                \
  HOST_CLASS_PROPERTY_ITEM_21(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20)                                                                                \
  HOST_CLASS_PROPERTY_ITEM(_21)
#define HOST_CLASS_PROPERTY_ITEM_23(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22)                                                           \
  HOST_CLASS_PROPERTY_ITEM_22(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21)                                                                           \
  HOST_CLASS_PROPERTY_ITEM(_22)
#define HOST_CLASS_PROPERTY_ITEM_24(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23)                                                      \
  HOST_CLASS_PROPERTY_ITEM_23(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22)                                                                      \
  HOST_CLASS_PROPERTY_ITEM(_23)
#define HOST_CLASS_PROPERTY_ITEM_25(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24)                                                 \
  HOST_CLASS_PROPERTY_ITEM_24(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23)                                                                 \
  HOST_CLASS_PROPERTY_ITEM(_24)
#define HOST_CLASS_PROPERTY_ITEM_26(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25)                                            \
  HOST_CLASS_PROPERTY_ITEM_25(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24)                                                            \
  HOST_CLASS_PROPERTY_ITEM(_25)
#define HOST_CLASS_PROPERTY_ITEM_27(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25, _26)                                       \
  HOST_CLASS_PROPERTY_ITEM_26(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24, _25)                                                       \
  HOST_CLASS_PROPERTY_ITEM(_26)
#define HOST_CLASS_PROPERTY_ITEM_28(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25, _26, _27)                                  \
  HOST_CLASS_PROPERTY_ITEM_27(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24, _25, _26)                                                  \
  HOST_CLASS_PROPERTY_ITEM(_27)
#define HOST_CLASS_PROPERTY_ITEM_29(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, _28)                             \
  HOST_CLASS_PROPERTY_ITEM_28(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24, _25, _26, _27)                                             \
  HOST_CLASS_PROPERTY_ITEM(_28)


#define HOST_OBJECT_PROPERTY_ITEM_1(_0) HOST_OBJECT_PROPERTY_ITEM(_0)
#define HOST_OBJECT_PROPERTY_ITEM_2(_0, _1) HOST_OBJECT_PROPERTY_ITEM_1(_0) HOST_OBJECT_PROPERTY_ITEM(_1)
#define HOST_OBJECT_PROPERTY_ITEM_3(_0, _1, _2) HOST_OBJECT_PROPERTY_ITEM_2(_0, _1) HOST_OBJECT_PROPERTY_ITEM(_2)
#define HOST_OBJECT_PROPERTY_ITEM_4(_0, _1, _2, _3) HOST_OBJECT_PROPERTY_ITEM_3(_0, _1, _2) HOST_OBJECT_PROPERTY_ITEM(_3)
#define HOST_OBJECT_PROPERTY_ITEM_5(_0, _1, _2, _3, _4)                                                                 \
  HOST_OBJECT_PROPERTY_ITEM_4(_0, _1, _2, _3) HOST_OBJECT_PROPERTY_ITEM(_4)
#define HOST_OBJECT_PROPERTY_ITEM_6(_0, _1, _2, _3, _4, _5)                                                             \
  HOST_OBJECT_PROPERTY_ITEM_5(_0, _1, _2, _3, _4) HOST_OBJECT_PROPERTY_ITEM(_5)
#define HOST_OBJECT_PROPERTY_ITEM_7(_0, _1, _2, _3, _4, _5, _6)                                                         \
  HOST_OBJECT_PROPERTY_ITEM_6(_0, _1, _2, _3, _4, _5) HOST_OBJECT_PROPERTY_ITEM(_6)
#define HOST_OBJECT_PROPERTY_ITEM_8(_0, _1, _2, _3, _4, _5, _6, _7)                                                     \
  HOST_OBJECT_PROPERTY_ITEM_7(_0, _1, _2, _3, _4, _5, _6) HOST_OBJECT_PROPERTY_ITEM(_7)
#define HOST_OBJECT_PROPERTY_ITEM_9(_0, _1, _2, _3, _4, _5, _6, _7, _8)                                                 \
  HOST_OBJECT_PROPERTY_ITEM_8(_0, _1, _2, _3, _4, _5, _6, _7) HOST_OBJECT_PROPERTY_ITEM(_8)
#define HOST_OBJECT_PROPERTY_ITEM_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9)                                            \
  HOST_OBJECT_PROPERTY_ITEM_9(_0, _1, _2, _3, _4, _5, _6, _7, _8) HOST_OBJECT_PROPERTY_ITEM(_9)
#define HOST_OBJECT_PROPERTY_ITEM_11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10)                                       \
  HOST_OBJECT_PROPERTY_ITEM_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9) HOST_OBJECT_PROPERTY_ITEM(_10)
#define HOST_OBJECT_PROPERTY_ITEM_12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11)                                  \
  HOST_OBJECT_PROPERTY_ITEM_11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) HOST_OBJECT_PROPERTY_ITEM(_11)
#define HOST_OBJECT_PROPERTY_ITEM_13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)                             \
  HOST_OBJECT_PROPERTY_ITEM_12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) HOST_OBJECT_PROPERTY_ITEM(_12)
#define HOST_OBJECT_PROPERTY_ITEM_14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13)                        \
  HOST_OBJECT_PROPERTY_ITEM_13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) HOST_OBJECT_PROPERTY_ITEM(_13)
#define HOST_OBJECT_PROPERTY_ITEM_15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)                   \
  HOST_OBJECT_PROPERTY_ITEM_14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) HOST_OBJECT_PROPERTY_ITEM(_14)
#define HOST_OBJECT_PROPERTY_ITEM_16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)              \
  HOST_OBJECT_PROPERTY_ITEM_15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)                         \
  HOST_OBJECT_PROPERTY_ITEM(_15)
#define HOST_OBJECT_PROPERTY_ITEM_17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)         \
  HOST_OBJECT_PROPERTY_ITEM_16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)                    \
  HOST_OBJECT_PROPERTY_ITEM(_16)
#define HOST_OBJECT_PROPERTY_ITEM_18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)    \
  HOST_OBJECT_PROPERTY_ITEM_17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)               \
  HOST_OBJECT_PROPERTY_ITEM(_17)
#define HOST_OBJECT_PROPERTY_ITEM_19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18)                                                                               \
  HOST_OBJECT_PROPERTY_ITEM_18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)          \
  HOST_OBJECT_PROPERTY_ITEM(_18)
#define HOST_OBJECT_PROPERTY_ITEM_20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19)                                                                          \
  HOST_OBJECT_PROPERTY_ITEM_19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18)     \
  HOST_OBJECT_PROPERTY_ITEM(_19)
#define HOST_OBJECT_PROPERTY_ITEM_21(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20)                                                                     \
  HOST_OBJECT_PROPERTY_ITEM_20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19)                                                                                     \
  HOST_OBJECT_PROPERTY_ITEM(_20)
#define HOST_OBJECT_PROPERTY_ITEM_22(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21)                                                                \
  HOST_OBJECT_PROPERTY_ITEM_21(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20)                                                                                \
  HOST_OBJECT_PROPERTY_ITEM(_21)
#define HOST_OBJECT_PROPERTY_ITEM_23(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22)                                                           \
  HOST_OBJECT_PROPERTY_ITEM_22(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21)                                                                           \
  HOST_OBJECT_PROPERTY_ITEM(_22)
#define HOST_OBJECT_PROPERTY_ITEM_24(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23)                                                      \
  HOST_OBJECT_PROPERTY_ITEM_23(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22)                                                                      \
  HOST_OBJECT_PROPERTY_ITEM(_23)
#define HOST_OBJECT_PROPERTY_ITEM_25(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24)                                                 \
  HOST_OBJECT_PROPERTY_ITEM_24(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23)                                                                 \
  HOST_OBJECT_PROPERTY_ITEM(_24)
#define HOST_OBJECT_PROPERTY_ITEM_26(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25)                                            \
  HOST_OBJECT_PROPERTY_ITEM_25(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24)                                                            \
  HOST_OBJECT_PROPERTY_ITEM(_25)
#define HOST_OBJECT_PROPERTY_ITEM_27(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25, _26)                                       \
  HOST_OBJECT_PROPERTY_ITEM_26(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24, _25)                                                       \
  HOST_OBJECT_PROPERTY_ITEM(_26)
#define HOST_OBJECT_PROPERTY_ITEM_28(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25, _26, _27)                                  \
  HOST_OBJECT_PROPERTY_ITEM_27(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24, _25, _26)                                                  \
  HOST_OBJECT_PROPERTY_ITEM(_27)
#define HOST_OBJECT_PROPERTY_ITEM_29(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, _28)                             \
  HOST_OBJECT_PROPERTY_ITEM_28(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24, _25, _26, _27)                                             \
  HOST_OBJECT_PROPERTY_ITEM(_28)

#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_1(_0) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_0)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_2(_0, _1) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_1(_0) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_1)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_3(_0, _1, _2) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_2(_0, _1) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_2)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_4(_0, _1, _2, _3) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_3(_0, _1, _2) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_3)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_5(_0, _1, _2, _3, _4)                                                                 \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_4(_0, _1, _2, _3) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_4)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_6(_0, _1, _2, _3, _4, _5)                                                             \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_5(_0, _1, _2, _3, _4) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_5)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_7(_0, _1, _2, _3, _4, _5, _6)                                                         \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_6(_0, _1, _2, _3, _4, _5) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_6)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_8(_0, _1, _2, _3, _4, _5, _6, _7)                                                     \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_7(_0, _1, _2, _3, _4, _5, _6) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_7)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_9(_0, _1, _2, _3, _4, _5, _6, _7, _8)                                                 \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_8(_0, _1, _2, _3, _4, _5, _6, _7) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_8)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9)                                            \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_9(_0, _1, _2, _3, _4, _5, _6, _7, _8) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_9)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10)                                       \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_10(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_10)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11)                                  \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_11(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_11)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)                             \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_12(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_12)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13)                        \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_13(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_13)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)                   \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_14(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_14)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)              \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_15(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14)                         \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_15)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)         \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_16(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15)                    \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_16)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)    \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_17(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16)               \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_17)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18)                                                                               \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_18(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17)          \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_18)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19)                                                                          \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_19(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18)     \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_19)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_21(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20)                                                                     \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19)                                                                                     \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_20)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_22(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21)                                                                \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_21(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20)                                                                                \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_21)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_23(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22)                                                           \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_22(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21)                                                                           \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_22)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_24(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23)                                                      \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_23(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22)                                                                      \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_23)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_25(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24)                                                 \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_24(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23)                                                                 \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_24)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_26(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25)                                            \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_25(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24)                                                            \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_25)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_27(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25, _26)                                       \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_26(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24, _25)                                                       \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_26)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_28(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25, _26, _27)                                  \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_27(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24, _25, _26)                                                  \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_27)
#define HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_29(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, \
                                    _18, _19, _20, _21, _22, _23, _24, _25, _26, _27, _28)                             \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_28(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18,     \
                              _19, _20, _21, _22, _23, _24, _25, _26, _27)                                             \
  HOST_CLASS_PROTOTYPE_PROPERTY_ITEM(_28)

#define DEFINE_HOST_CLASS_PROPERTY(ARGS_COUNT, ...) HOST_CLASS_PROPERTY_ITEM_##ARGS_COUNT(__VA_ARGS__)
#define DEFINE_HOST_CLASS_PROTOTYPE_PROPERTY(ARGS_COUNT, ...) HOST_CLASS_PROTOTYPE_PROPERTY_ITEM_##ARGS_COUNT(__VA_ARGS__)
#define DEFINE_HOST_OBJECT_PROPERTY(ARGS_COUNT, ...) HOST_OBJECT_PROPERTY_ITEM_##ARGS_COUNT(__VA_ARGS__)

#endif // KRAKENBRIDGE_JS_CONTEXT_MACROS_H
