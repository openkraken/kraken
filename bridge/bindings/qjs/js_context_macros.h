/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_JS_CONTEXT_MACROS_H
#define KRAKENBRIDGE_JS_CONTEXT_MACROS_H

#define OBJECT_INSTANCE(NAME)                                                 \
  static NAME* instance(JSContext* context) {                                 \
    if (context->constructorMap.count(#NAME) == 0) {                          \
      context->constructorMap[#NAME] = static_cast<void*>(new NAME(context)); \
    }                                                                         \
    return static_cast<NAME*>(context->constructorMap[#NAME]);                \
  }

#define QJS_GLOBAL_BINDING_FUNCTION(context, function, name, argc)     \
  {                                                                    \
    JSValue f = JS_NewCFunction(context->ctx(), function, name, argc); \
    context->defineGlobalProperty(name, f);                            \
  }

#define IMPL_PROPERTY_GETTER(Constructor, Property) JSValue Constructor::Property##PropertyDescriptor::getter
#define IMPL_PROPERTY_SETTER(Constructor, Property) JSValue Constructor::Property##PropertyDescriptor::setter

#define DEFINE_PROTOTYPE_READONLY_PROPERTY(PROPERTY)                                             \
  class PROPERTY##PropertyDescriptor {                                                           \
   public:                                                                                       \
    static JSValue getter(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
  };                                                                                             \
  ObjectProperty __##PROPERTY##__ { m_context, m_prototypeObject, #PROPERTY, PROPERTY##PropertyDescriptor::getter }

#define DEFINE_PROTOTYPE_FUNCTION(PROPERTY, ARGS_COUNT) \
  ObjectFunction __##PROPERTY##__ { m_context, m_prototypeObject, #PROPERTY, PROPERTY, ARGS_COUNT }

#define DEFINE_FUNCTION(PROPERTY, ARGS_COUNT) \
  ObjectFunction __##PROPERTY##__ { m_context, jsObject, #PROPERTY, PROPERTY, ARGS_COUNT }

#define DEFINE_PROTOTYPE_PROPERTY(PROPERTY)                                                      \
  class PROPERTY##PropertyDescriptor {                                                           \
   public:                                                                                       \
    static JSValue getter(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
    static JSValue setter(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
  };                                                                                             \
  ObjectProperty __##PROPERTY##__ { m_context, m_prototypeObject, #PROPERTY, PROPERTY##PropertyDescriptor::getter, PROPERTY##PropertyDescriptor::setter }

#define DEFINE_READONLY_PROPERTY(PROPERTY)                                                       \
  class PROPERTY##PropertyDescriptor {                                                           \
   public:                                                                                       \
    static JSValue getter(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
  };                                                                                             \
  ObjectProperty __##PROPERTY##__ { m_context, jsObject, #PROPERTY, PROPERTY##PropertyDescriptor::getter }

#define DEFINE_PROPERTY(PROPERTY)                                                                \
  class PROPERTY##PropertyDescriptor {                                                           \
   public:                                                                                       \
    static JSValue getter(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
    static JSValue setter(QjsContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
  };                                                                                             \
  ObjectProperty __##PROPERTY##__ { m_context, jsObject, #PROPERTY, PROPERTY##PropertyDescriptor::getter, PROPERTY##PropertyDescriptor::setter }

#endif  // KRAKENBRIDGE_JS_CONTEXT_MACROS_H
