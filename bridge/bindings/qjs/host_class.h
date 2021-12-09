/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HOST_CLASS_H
#define KRAKENBRIDGE_HOST_CLASS_H

#include "js_context.h"
#include "qjs_patch.h"
#include "third_party/quickjs/quickjs.h"

namespace kraken::binding::qjs {

class Instance;

class HostClass {
 public:
  KRAKEN_DISALLOW_COPY_AND_ASSIGN(HostClass);

  HostClass(JSContext* context, std::string name) : m_context(context), m_name(std::move(name)), m_ctx(context->ctx()), m_contextId(context->getContextId()) {
    /// JavaScript object in QuickJS are created by template, in QuickJS, these template is called JSClassDef.
    /// JSClassDef define this JSObject's base behavior like className, property getter and setter, and advanced feature such as run a callback when JSObject had been freed by QuickJS garbage
    /// collector. Every JSClassDef must have a unique ID, called JSClassID, you can obtain this ID from JS_NewClassID() API. If your wants to create JSObjects defined by your own template, please
    /// follow this steps:
    /// 1. Use JS_NewClassID() to allocate new id for your template.
    /// 2. Create JSClassDef and set up your customized behavior about your JSObject.
    /// 3. Use JS_NewClass() to initialize your template and you can use your unique JSClassID to create JSObjects.
    /// 4. Use JS_NewObjectClass() to create your JSObjects.
    /// Example:
    ///  JSClassID sampleId;
    ///  JS_NewClassID(&sampleId);
    ///
    ///  JSClassDef def{};
    ///  def.class_name = "SampleClass";
    ///  def.finalizer = [](JSRuntime* rt, JSValue val) {
    ///    // Do something when jsObject been freed by GC
    ///  };
    ///  def.call = [](QjsContext * ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) -> JSValue {
    ///    // Do something when jsObject been called as function or called as constructor.
    ///  };
    ///  JS_NewClass(runtime, sampleId, &def);
    ///  JSValue jsObject = JS_NewObjectClass(ctx, sampleId);
    JSClassDef def{};
    def.class_name = "HostClass";
    def.finalizer = proxyFinalize;
    def.call = proxyCall;
    JS_NewClass(context->runtime(), JSContext::kHostClassClassId, &def);
    jsObject = JS_NewObjectClass(context->ctx(), JSContext::kHostClassClassId);
    m_prototypeObject = JS_NewObject(m_ctx);

    // Make constructor function inherit to Function.prototype
    JSValue functionConstructor = JS_GetPropertyStr(m_ctx, m_context->global(), "Function");
    JSValue functionPrototype = JS_GetPropertyStr(m_ctx, functionConstructor, "prototype");
    JS_SetPrototype(m_ctx, jsObject, functionPrototype);
    JS_FreeValue(m_ctx, functionPrototype);
    JS_FreeValue(m_ctx, functionConstructor);

    JSAtom prototypeKey = JS_NewAtom(m_ctx, "prototype");
    JS_DefinePropertyValue(m_ctx, jsObject, prototypeKey, m_prototypeObject, JS_PROP_C_W_E);
    JS_FreeAtom(m_ctx, prototypeKey);

    JS_SetConstructorBit(m_ctx, jsObject, true);
    JS_SetOpaque(jsObject, this);
  };
  virtual ~HostClass() = default;

  virtual JSValue instanceConstructor(QjsContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValueConst* argv) { return JS_NewObject(ctx); };
  JSValue jsObject;

  inline uint32_t contextId() const { return m_contextId; }
  inline JSContext* context() const { return m_context; }
  inline JSValue prototype() const { return m_prototypeObject; };

 protected:
  JSValue m_prototypeObject{JS_NULL};
  std::string m_name;
  JSContext* m_context;
  int32_t m_contextId;
  QjsContext* m_ctx;

 private:
  friend Instance;
  static void proxyFinalize(JSRuntime* rt, JSValue val) {
    auto hostObject = static_cast<HostClass*>(JS_GetOpaque(val, JSContext::kHostClassClassId));
    if (hostObject->context()->isValid()) {
      JS_FreeValue(hostObject->m_ctx, hostObject->jsObject);
    }
    delete hostObject;
  };
  static JSValue proxyCall(QjsContext* ctx, JSValueConst func_obj, JSValueConst this_val, int argc, JSValueConst* argv, int flags) {
    // This jsObject is called as a constructor.
    if ((flags & JS_CALL_FLAG_CONSTRUCTOR) != 0) {
      auto* hostClass = static_cast<HostClass*>(JS_GetOpaque(func_obj, JSContext::kHostClassClassId));
      JSValue instance = hostClass->instanceConstructor(ctx, func_obj, this_val, argc, argv);
      JSValue proto = JS_GetPropertyStr(ctx, this_val, "prototype");
      JS_SetPrototype(ctx, instance, proto);
      JS_FreeValue(ctx, proto);
      return instance;
    }

    return this_val;
  }
};

class Instance {
 public:
  explicit Instance(HostClass* hostClass, std::string name, JSClassExoticMethods* exotic, JSClassID classId, JSClassFinalizer finalizer)
      : m_context(hostClass->context()), m_hostClass(hostClass), m_name(std::move(name)), m_ctx(m_context->ctx()), m_contextId(hostClass->contextId()) {
    JSClassDef def{};
    def.class_name = m_name.c_str();
    def.finalizer = finalizer;
    def.exotic = exotic;
    def.gc_mark = proxyGCMark;
    int32_t success = JS_NewClass(m_context->runtime(), classId, &def);
    jsObject = JS_NewObjectProtoClass(m_ctx, hostClass->m_prototypeObject, classId);
    JS_SetOpaque(jsObject, this);
  };
  JSValue jsObject;
  virtual ~Instance() = default;

  inline HostClass* prototype() const { return m_hostClass; }
  inline JSContext* context() const { return m_context; }
  inline std::string name() const { return m_name; }

 private:
  static void proxyGCMark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func) {
    auto* instance = static_cast<Instance*>(JS_GetOpaque(val, JSValueGetClassId(val)));
    instance->gcMark(rt, val, mark_func);
  }

 protected:
  virtual void gcMark(JSRuntime* rt, JSValueConst val, JS_MarkFunc* mark_func){};

  JSContext* m_context{nullptr};
  QjsContext* m_ctx{nullptr};
  HostClass* m_hostClass{nullptr};
  std::string m_name;
  int64_t m_contextId{-1};

  friend HostClass;
};

}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_HOST_CLASS_H
