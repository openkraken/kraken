<% if (object.construct) { %>
JSValue QJS<%= className %>::ConstructorCallback(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv, int flags) {
  <%= generateFunctionBody(blob, object.construct, {isConstructor: true}) %>
}
<% } %>

<% if (object.indexedProp) { %>
  <% if (object.indexedProp.indexKeyType == 'number') { %>
  JSValue QJS<%= className %>::IndexedPropertyGetterCallback(JSContext* ctx, JSValue obj, uint32_t index) {
    auto* self = toScriptWrappable<NodeList>(obj);
    if (index >= self->length()) {
      return JS_UNDEFINED;
    }
    ExceptionState exception_state;
    <%= generateTypeValue(object.indexedProp.type) %> result = self->item(index, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return exception_state.ToQuickJS();
    }
    return result->ToQuickJS();
  };
  <% } else { %>
  JSValue QJS<%= className %>::StringPropertyGetterCallback(JSContext* ctx, JSValue obj, JSAtom key) {
    auto* self = toScriptWrappable<NodeList>(obj);
    ExceptionState exception_state;
    ${generateTypeValue(object.indexedProp.type)} result = self->item(key, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return exception_state.ToQuickJS();
    }
    return result->ToQuickJS();
  };
  <% } %>
  <% if (!object.indexedProp.readonly) { %>
    <% if (object.indexedProp.indexKeyType == 'number') { %>
  bool QJS<%= className %>::IndexedPropertySetterCallback(JSContext* ctx, JSValueConst obj, uint32_t index, JSValueConst value) {
    auto* self = toScriptWrappable<NodeList>(obj);
    ExceptionState exception_state;
    MemberMutationScope scope{ExecutingContext::From(ctx)};
    bool success = self->SetItem(index, value, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return false;
    }
    return success;
  };
    <% } else { %>
  bool QJS<%= className %>::StringPropertySetterCallback(JSContext* ctx, JSValueConst obj, JSAtom key, JSValueConst value) {
    auto* self = toScriptWrappable<NodeList>(obj);
    ExceptionState exception_state;
    MemberMutationScope scope{ExecutingContext::From(ctx)};
    bool success = self->SetItem(key, value, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return false;
    }
    return success;
  };
    <% } %>
  <% } %>
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
  MemberMutationScope scope{ExecutingContext::From(ctx)};

  <%= blob.filename %>->set<%= prop.name[0].toUpperCase() + prop.name.slice(1) %>(v, exception_state);
  if (exception_state.HasException()) {
    return exception_state.ToQuickJS();
  }

  return JS_DupValue(ctx, argv[0]);
}
<% } %>
<% }); %>
