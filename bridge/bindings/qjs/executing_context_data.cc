/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */


#include "executing_context_data.h"
#include "executing_context.h"

namespace kraken::binding::qjs {

JSValue ExecutionContextData::constructorForType(const WrapperTypeInfo* type) {
  auto it = m_constructorMap.find(type);
  return it != m_constructorMap.end() ? it->second : constructorForIdSlowCase(type);
}

JSValue ExecutionContextData::prototypeForType(const WrapperTypeInfo* type) {
  auto it = m_prototypeMap.find(type);

  // Constructor not initialized, create it.
  if (it == m_prototypeMap.end()) {
    constructorForIdSlowCase(type);
    it = m_prototypeMap.find(type);
  }

  return it != m_prototypeMap.end() ? it->second : JS_NULL;
}

JSValue ExecutionContextData::constructorForIdSlowCase(const WrapperTypeInfo* type) {
  JSRuntime* runtime = m_context->runtime();
  JSContext* ctx = m_context->ctx();

  assert(type->classId == 0 || !JS_HasClassId(runtime, type->classId));

  // Allocate a new unique classID from QuickJS.
  JS_NewClassID(const_cast<JSClassID*>(&type->classId));

  // Create class template for behavior.
  JSClassDef def{};
  def.class_name = type->className;
  def.call = type->callFunc;
  JS_NewClass(m_context->runtime(), type->classId, &def);

  // Create class object and prototype object.
  JSValue classObject = m_constructorMap[type] = JS_NewObjectClass(m_context->ctx(), type->classId);
  JSValue prototypeObject = m_prototypeMap[type] = JS_NewObject(m_context->ctx());

  // Make constructor function inherit to Function.prototype
  JSValue functionConstructor = JS_GetPropertyStr(ctx, m_context->global(), "Function");
  JSValue functionPrototype = JS_GetPropertyStr(ctx, functionConstructor, "prototype");
  JS_SetPrototype(ctx, classObject, functionPrototype);
  JS_FreeValue(ctx, functionPrototype);
  JS_FreeValue(ctx, functionConstructor);

  // Bind class object and prototype object.
  JSAtom prototypeKey = JS_NewAtom(ctx, "prototype");
  JS_DefinePropertyValue(ctx, classObject, prototypeKey, prototypeObject, JS_PROP_C_W_E);
  JS_FreeAtom(ctx, prototypeKey);

  // Inherit to parentClass.
  if (type->parent_class != nullptr) {
    assert(m_prototypeMap.count(type->parent_class) > 0);
    JS_SetPrototype(m_context->ctx(), prototypeObject, m_prototypeMap[type->parent_class]);
  }

  // Configure to be called as a constructor.
  JS_SetConstructorBit(ctx, classObject, true);

  // Store WrapperTypeInfo as private data.
  JS_SetOpaque(classObject, (void*)type);

  return classObject;
}

}
