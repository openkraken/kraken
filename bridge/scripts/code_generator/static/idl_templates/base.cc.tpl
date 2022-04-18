/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

#include "<%= blob.filename %>.h"
#include "bindings/qjs/member_installer.h"
#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/converter_impl.h"
#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/script_promise.h"
#include "core/executing_context.h"

namespace kraken {

<% if (wrapperTypeInfoInit) { %>
<%= wrapperTypeInfoInit %>
<% } %>
<%= content %>

<% if (globalFunctionInstallList.length > 0 || classPropsInstallList.length > 0 || classMethodsInstallList.length > 0 || constructorInstallList.length > 0) { %>
void QJS<%= className %>::Install(ExecutingContext* context) {
  <% if (globalFunctionInstallList.length > 0) { %> InstallGlobalFunctions(context); <% } %>
  <% if(classPropsInstallList.length > 0) { %> InstallPrototypeProperties(context); <% } %>
  <% if(classMethodsInstallList.length > 0) { %> InstallPrototypeMethods(context); <% } %>
  <% if(constructorInstallList.length > 0) { %> InstallConstructor(context); <% } %>
}

<% } %>

<% if(globalFunctionInstallList.length > 0) { %>
void QJS<%= className %>::InstallGlobalFunctions(ExecutingContext* context) {
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    <%= globalFunctionInstallList.join(',\n') %>
  };
  MemberInstaller::InstallFunctions(context, context->Global(), functionConfig);
}
<% } %>

<% if(classPropsInstallList.length > 0) { %>
void QJS<%= className %>::InstallPrototypeProperties(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    <%= classPropsInstallList.join(',\n') %>
  };
  MemberInstaller::InstallFunctions(context, prototype, functionConfig);
}
<% } %>

<% if(classMethodsInstallList.length > 0) { %>
void QJS<%= className %>::InstallPrototypeMethods(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributesConfig {
    <%= classMethodsInstallList.join(',\n') %>
  };

  MemberInstaller::InstallAttributes(context, prototype, attributesConfig);
}
<% } %>

<% if (constructorInstallList.length > 0) { %>
void QJS<%= className %>::InstallConstructor(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue constructor = context->contextData()->constructorForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributeConfig {
    <%= constructorInstallList.join(',\n') %>
  };
  MemberInstaller::InstallAttributes(context, context->Global(), attributeConfig);
}
<% } %>

}
