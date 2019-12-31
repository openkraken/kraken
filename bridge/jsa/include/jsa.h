/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef JSA_JSA_H_
#define JSA_JSA_H_

#include "js_context.h"
#include "js_error.h"
#include "js_type.h"
#include "instrumentation.h"
#include "macros.h"

//#ifdef KRAKEN_JSC_ENGINE
#include "jsc/jsc_implementation.h"
#define CREATE_JS_CONTEXT alibaba::jsc::createJSContext();
//#endif

//#define CREATE_JS_CONTEXT(code, url, line) \
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
    alibaba::jsa::Function::createFromHostFunction(rt, alibaba::jsa::PropNameID::forUtf8(rt, name), paramCount, func);

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

#endif // JSA_JSA_H_
