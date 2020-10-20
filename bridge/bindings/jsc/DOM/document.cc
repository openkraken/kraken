/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "document.h"
#include "bindings/jsc/macros.h"
#include <mutex>

namespace kraken::binding::jsc {

std::once_flag documentDefinition;
JSClassRef documentClass;

void bindDocument(std::unique_ptr<JSContext> &context) {
  std::call_once(documentDefinition, []() {
    JSClassDefinition definition = kJSClassDefinitionEmpty;
    definition.version = 0;
    definition.className = "Document";
    definition.attributes = kJSClassAttributeNoAutomaticPrototype;
    definition.finalize = JSDocument::finalize;
    definition.getProperty = JSDocument::getProperty;
    definition.setProperty = JSDocument::setProperty;
    definition.hasProperty = JSDocument::hasProperty;
    definition.getPropertyNames = JSDocument::getPropertyNames;
    documentClass = JSClassCreate(&definition);
  });
  std::map<std::string, JSObjectCallAsFunctionCallback> properties {};
  JSC_BINDING_OBJECT(context, "document", documentClass, new JSDocument(context, properties));
}

} // namespace kraken::binding::jsc
