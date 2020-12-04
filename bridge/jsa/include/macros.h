/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef JSA_MACROS_H_
#define JSA_MACROS_H_

#ifndef __has_builtin
#define __has_builtin(x) 0
#endif

#if defined(ANDROID)
#define IS_ANDROID 1
#elif defined(__APPLE__)
// only include TargetConditions after testing ANDROID as some android builds
// on mac don't have this header available and it's not needed unless the target
// is really mac/ios.
#include <TargetConditionals.h>
#define IS_MACOSX 1
#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
#define IS_IOS 1
#endif // defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE
#elif defined(__linux__)
#define IS_LINUX 1
// include a system header to pull in features.h for glibc/uclibc macros.
#include <unistd.h>
#if defined(__GLIBC__) && !defined(__UCLIBC__)
// we really are using glibc, not uClibc pretending to be glibc
#define LIBC_GLIBC 1
#endif
#elif defined(_WIN32)
#define IS_WIN 1
#elif defined(__FreeBSD__)
#define IS_FREEBSD 1
#elif defined(__OpenBSD__)
#define IS_OPENBSD 1
#elif defined(__sun)
#define IS_SOLARIS 1
#elif defined(__QNXNTO__)
#define IS_QNX 1
#else
#error Please add support for your platform in build_config.h
#endif

#if __has_builtin(__builtin_expect) || defined(__GNUC__)
#define JSC_LIKELY(EXPR) __builtin_expect((bool)(EXPR), true)
#define JSC_UNLIKELY(EXPR) __builtin_expect((bool)(EXPR), false)
#else
#define JSC_LIKELY(EXPR) (EXPR)
#define JSC_UNLIKELY(EXPR) (EXPR)
#endif

#define JSC_ASSERT(x)                                                                                                  \
  do {                                                                                                                 \
    if (JSC_UNLIKELY(!!(x))) {                                                                                         \
      abort();                                                                                                         \
    }                                                                                                                  \
  } while (0)

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
// This takes care of watch and tvos (due to backwards compatibility in
// Availability.h
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
#define _JSC_FAST_IS_ARRAY
#endif
#endif
#if defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#if __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_11
// Only one of these should be set for a build.  If somehow that's not
// true, this will be a compile-time error and it can be resolved when
// we understand why.
#define _JSC_FAST_IS_ARRAY
#endif
#endif

// binding hostFunctionType functions into object
#define JSA_BINDING_FUNCTION(context, obj, name, paramCount, func)                                                     \
  {                                                                                                                    \
    auto _name = alibaba::jsa::PropNameID::forUtf8(context, name);                                                     \
    obj.setProperty(context, _name, alibaba::jsa::Function::createFromHostFunction(context, _name, paramCount, func)); \
  }

#define JSA_BINDING_CLASS(context, obj, name, paramCount, func, prototype)                                             \
  {                                                                                                                    \
    auto _name = alibaba::jsa::PropNameID::forUtf8(context, name);                                                     \
    obj.setProperty(context, _name, alibaba::jsa::Function::createFromHostClass(context, _name, paramCount, func, prototype)); \
  }

#define HOST_FUNCTION_TO_VALUE(context, name, paramCount, func) \
  alibaba::jsa::Function::createFromHostFunction(context, alibaba::jsa::PropNameID::forAscii(context, name), paramCount, func)

#define EMPLACE_PROPERTY_NAMES(context, propertyNames, name) \
  propertyNames.emplace_back(alibaba::jsa::PropNameID::forUtf8(context, name))

#define JSA_CREATE_OBJECT(context) alibaba::jsa::Object(context)

#define JSA_CREATE_HOST_FUNCTION(context, name, paramCount, func)                                                      \
  alibaba::jsa::Function::createFromHostFunction(context, alibaba::jsa::PropNameID::forUtf8(context, name),            \
                                                 paramCount, func);

#define JSA_SET_PROPERTY(context, obj, name, value) obj.setProperty(context, name, value)

#define JSA_GET_PROPERTY(context, obj, name) obj.getProperty(context, name)

#endif
