/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_CONTEXT_MACROS_H
#define KRAKENBRIDGE_CONTEXT_MACROS_H

#define QJS_GLOBAL_BINDING_FUNCTION(context, function, name, argc)     \
  {                                                                    \
    JSValue f = JS_NewCFunction(context->ctx(), function, name, argc); \
    context->defineGlobalProperty(name, f);                            \
  }

#define IMPL_PROPERTY_GETTER(Constructor, Property) JSValue Constructor::Property##PropertyDescriptor::getter
#define IMPL_PROPERTY_SETTER(Constructor, Property) JSValue Constructor::Property##PropertyDescriptor::setter

#define INSTALL_READONLY_PROPERTY(Host, thisObject, property) \
  installPropertyGetter(context.get(), thisObject, #property, Host::property##PropertyDescriptor::getter)

#define INSTALL_PROPERTY(Host, thisObject, property) \
  installPropertyGetterSetter(context.get(), thisObject, #property, Host::property##PropertyDescriptor::getter, Host::property##PropertyDescriptor::setter)

#define INSTALL_FUNCTION(Host, thisObject, property, argc) \
  installFunctionProperty(context.get(), thisObject, #property, Host::m_##property##_, 1);

#define DEFINE_FUNCTION(NAME) \
    static JSValue m_##NAME##_(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv);

#define IMPL_FUNCTION(Host, NAME) JSValue Host::m_##NAME##_


#define DEFINE_PROTOTYPE_READONLY_PROPERTY(PROPERTY)                                            \
  class PROPERTY##PropertyDescriptor {                                                          \
   public:                                                                                      \
    static JSValue getter(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
  };                                                                                            \

#define DEFINE_PROTOTYPE_PROPERTY(PROPERTY)                                                     \
  class PROPERTY##PropertyDescriptor {                                                          \
   public:                                                                                      \
    static JSValue getter(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
    static JSValue setter(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
  };                                                                                            \

#define DEFINE_READONLY_PROPERTY(PROPERTY)                                                      \
  class PROPERTY##PropertyDescriptor {                                                          \
   public:                                                                                      \
    static JSValue getter(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
  };                                                                                            \

#define DEFINE_PROPERTY(PROPERTY)                                                               \
  class PROPERTY##PropertyDescriptor {                                                          \
   public:                                                                                      \
    static JSValue getter(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
    static JSValue setter(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv); \
  };                                                                                            \

#endif  // KRAKENBRIDGE_CONTEXT_MACROS_H
