<% if (object.construct) { %>
JSValue QJS<%= className %>::ConstructorCallback(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv, int flags) {
  <%= generateFunctionBody(blob, object.construct, {isConstructor: true}) %>
}
<% } %>

<% _.forEach(filtedMethods, function(method, index) { %>

  <% if (overloadMethods[method.name] && overloadMethods[method.name].length > 1) { %>
    <% _.forEach(overloadMethods[method.name], function(overloadMethod, index) { %>
static JSValue <%= overloadMethod.name %>_overload_<%= index %>(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
        <%= generateFunctionBody(blob, overloadMethod, {isInstanceMethod: true}) %>
      }
    <% }); %>
    static JSValue <%= method.name %>(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
      <%= generateOverLoadSwitchBody(overloadMethods[method.name]) %>
    }
  <% } else { %>

  static JSValue <%= method.name %>(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
    <%= generateFunctionBody(blob, method, {isInstanceMethod: true}) %>
  }
  <% } %>

<% }) %>

<% _.forEach(object.props, function(prop, index) { %>
static JSValue <%= prop.name %>AttributeGetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* <%= blob.filename %> = toScriptWrappable<<%= className %>>(this_val);
  assert(<%= blob.filename %> != nullptr);
  return Converter<<%= generateTypeConverter(prop.type) %>>::ToValue(ctx, <%= blob.filename %>-><%= prop.name %>());
}
<% if (!prop.readonly) { %>
static JSValue <%= prop.name %>AttributeSetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
 auto* <%= blob.filename %> = toScriptWrappable<<%= className %>>(this_val);
  ExceptionState exception_state;
  auto&& v = Converter<<%= generateTypeConverter(prop.type) %>>::FromValue(ctx, argv[0], exception_state);
  if (exception_state.HasException()) {
    return exception_state.ToQuickJS();
  }
  <%= blob.filename %>->set<%= prop.name[0].toUpperCase() + prop.name.slice(1) %>(v);
  return JS_DupValue(ctx, argv[0]);
}
<% } %>
<% }); %>
