#include "core/<%= blob.implement %>.h"

namespace kraken {

class ExecutingContext;

class QJS<%= className %> : public QJSInterfaceBridge<QJS<%= className %>, <%= className%>> {
 public:
  static void Install(ExecutingContext* context);
  static WrapperTypeInfo* GetWrapperTypeInfo() {
    return const_cast<WrapperTypeInfo*>(&wrapper_type_info_);
  }
  <% if (object.construct) { %> static JSValue ConstructorCallback(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv, int flags); <% } %>
  static const WrapperTypeInfo wrapper_type_info_;
 private:
 <% if (globalFunctionInstallList.length > 0) { %> static void InstallGlobalFunctions(ExecutingContext* context); <% } %>
 <% if (classMethodsInstallList.length > 0) { %> static void InstallPrototypeMethods(ExecutingContext* context); <% } %>
 <% if (classPropsInstallList.length > 0) { %> static void InstallPrototypeProperties(ExecutingContext* context); <% } %>
 <% if (object.construct) { %> static void InstallConstructor(ExecutingContext* context); <% } %>

 <% if (object.indexedProp) { %>
  <% if (object.indexedProp.indexKeyType == 'number') { %>
  static JSValue IndexedPropertyGetterCallback(JSContext* ctx, JSValue obj, uint32_t index);
  <% } else { %>
  static JSValue StringPropertyGetterCallback(JSContext* ctx, JSValue obj, JSAtom key);
  <% } %>
  <% if (!object.indexedProp.readonly) { %>

    <% if (object.indexedProp.indexKeyType == 'number') { %>
  static bool IndexedPropertySetterCallback(JSContext* ctx, JSValueConst obj, uint32_t index, JSValueConst value);
    <% } else { %>
  static bool StringPropertySetterCallback(JSContext* ctx, JSValueConst obj, JSAtom key, JSValueConst value);
    <% } %>
  <% } %>
 <% } %>
};


}
