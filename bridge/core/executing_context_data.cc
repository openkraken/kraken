/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "executing_context_data.h"
#include "executing_context.h"

namespace kraken {

JSValue ExecutionContextData::constructorForType(const WrapperTypeInfo* type) {
  auto it = constructor_map_.find(type);
  return it != constructor_map_.end() ? it->second : constructorForIdSlowCase(type);
}

JSValue ExecutionContextData::prototypeForType(const WrapperTypeInfo* type) {
  auto it = prototype_map_.find(type);

  // Constructor not initialized, create it.
  if (it == prototype_map_.end()) {
    constructorForIdSlowCase(type);
    it = prototype_map_.find(type);
  }

  return it != prototype_map_.end() ? it->second : JS_NULL;
}

JSValue ExecutionContextData::constructorForIdSlowCase(const WrapperTypeInfo* type) {
  JSContext* ctx = m_context->ctx();

  JSClassID class_id{0};
  // Allocate a new unique classID from QuickJS.
  JS_NewClassID(&class_id);

  assert(class_id < JS_CLASS_GC_TRACKER);

  // Create class template for behavior.
  JSClassDef def{};
  def.class_name = type->className;
  def.call = type->callFunc;
  JS_NewClass(ScriptState::runtime(), class_id, &def);

  // Create class object and prototype object.
  JSValue classObject = constructor_map_[type] = JS_NewObjectClass(m_context->ctx(), class_id);
  JSValue prototypeObject = prototype_map_[type] = JS_NewObject(m_context->ctx());

  // Make constructor function inherit to Function.prototype
  JSValue functionConstructor = JS_GetPropertyStr(ctx, m_context->Global(), "Function");
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
    assert(prototype_map_.count(type->parent_class) > 0);
    JS_SetPrototype(m_context->ctx(), prototypeObject, prototype_map_[type->parent_class]);
  }

  // Configure to be called as a constructor.
  JS_SetConstructorBit(ctx, classObject, true);

  // Store WrapperTypeInfo as private data.
  JS_SetOpaque(classObject, (void*)type);

  return classObject;
}

void ExecutionContextData::Dispose() {
  for (auto& entry : prototype_map_) {
    JS_FreeValueRT(ScriptState::runtime(), entry.second);
  }

  for (auto& entry : constructor_map_) {
    JS_FreeValueRT(ScriptState::runtime(), entry.second);
  }
}

}  // namespace kraken
