/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef JSA_MACROS_H_
#define JSA_MACROS_H_

#ifndef __has_builtin
#define __has_builtin(x) 0
#endif

#if __has_builtin(__builtin_expect) || defined(__GNUC__)
#define JSC_LIKELY(EXPR) __builtin_expect((bool)(EXPR), true)
#define JSC_UNLIKELY(EXPR) __builtin_expect((bool)(EXPR), false)
#else
#define JSC_LIKELY(EXPR) (EXPR)
#define JSC_UNLIKELY(EXPR) (EXPR)
#endif

#define JSC_ASSERT(x)                                                          \
  do {                                                                         \
    if (JSC_UNLIKELY(!!(x))) {                                                 \
      abort();                                                                 \
    }                                                                          \
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

// set/get属性
#define JSA_SET_PROPERTY(rt, obj, name, value)                                 \
  (obj).setProperty((rt), name, value)
#define JSA_GET_PROPERTY(rt, obj, name) (obj).getProperty((rt), name)

// 在globalObject上set/get属性
// rt: JSContext&。JS运行时
// name: string。属性名
// value: jsa::Value。属性值
#define JSA_GLOBAL_SET_PROPERTY(rt, name, value)                               \
  (rt).global().setProperty(rt, name, value)
#define JSA_GLOBAL_GET_PROPERTY(rt, name) (rt).global().getProperty((rt), name)

// 往obj上注入函数
//
// rt: JSContext&
// obj: Object&。目标对象
// name: 函数名
// paramCount: 参数个数
// func: jsa::HostFunctionType。函数
#define JSA_BINDING_FUNCTION(rt, obj, name, paramCount, func)                  \
  {                                                                            \
    auto _name = alibaba::jsa::PropNameID::forUtf8(rt, name);                  \
    JSA_SET_PROPERTY(rt, obj, _name,                                           \
                     alibaba::jsa::Function::createFromHostFunction(           \
                         rt, _name, paramCount, func));                        \
  }

// 往obj上注入函数。简化版本，函数名与JS名称一致。
// rt: JSContext&
// obj: 目标对象
// func: 函数
#define JSA_BINDING_FUNCTION_SIMPLIFIED(rt, obj, func)                         \
  JSA_BINDING_FUNCTION(rt, obj, #func, 0, func)

// 与JSA_BINDING_FUNCTION类似，往globalObject上注入函数
#define JSA_BINDING_GLOBAL_FUNCTION(rt, name, paramCount, func)                \
  {                                                                            \
    auto _name = alibaba::jsa::PropNameID::forUtf8(rt, name);                  \
    JSA_GLOBAL_SET_PROPERTY(rt, _name,                                         \
                            alibaba::jsa::Function::createFromHostFunction(    \
                                rt, _name, paramCount, func));                 \
  }

// 与JSA_BINDING_FUNCTION类似，往globalObject上注入函数
#define JSA_BINDING_GLOBAL_FUNCTION_SIMPLIFIED(rt, func)                       \
  JSA_BINDING_GLOBAL_FUNCTION(rt, #func, 0, func)

// 创建普通jsObject
#define JSA_CREATE_OBJECT(rt) alibaba::jsa::Object(rt)

// 创建一个JSBinding
// 使用JSA_BINDING_GLOBAL_FUNCTION/JSA_BINDING_FUNCTION来注入
#define JSA_CREATE_HOST_FUNCTION(rt, name, paramCount, func)                   \
  alibaba::jsa::Function::createFromHostFunction(                              \
      rt, alibaba::jsa::PropNameID::forUtf8(rt, name), paramCount, func);

// 与JSA_CREATE_HOST_FUNCTION类似，创建一个JSBinding函数。
#define JSA_CREATE_HOST_FUNCTION_SIMPLIFIED(rt, func)                          \
  JSA_CREATE_HOST_FUNCTION(rt, #func, 0, func)

// 创建宿主JSObject
// host_obj: jsa::HostObject
#define JSA_CREATE_HOST_OBJECT(rt, host_obj)                                   \
  alibaba::jsa::Object::createFromHostObject(rt, host_obj)

// 往global上注入宿主对象。
// rt: JSContext&
// name: 名称
// host_obj: jsa::HostObject
#define JSA_BINDING_GLOBAL_HOST_OBJECT(rt, name, host_obj)                     \
  JSA_GLOBAL_SET_PROPERTY(                                                     \
      rt, name, alibaba::jsa::Object::createFromHostObject(rt, host_obj))

#endif
