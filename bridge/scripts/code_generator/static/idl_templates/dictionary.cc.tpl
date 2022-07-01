std::shared_ptr<<%= className %>> <%= className %>::Create() {
  return std::make_shared<<%= className %>>();
}
std::shared_ptr<<%= className %>> <%= className %>::Create(JSContext* ctx, JSValue value, ExceptionState& exception_state) {
  return std::make_shared<<%= className %>>(ctx, value, exception_state);
}

<%= className %>::<%= className %>() <%= generateDictionaryInit(blob, props) %> {}
<%= className %>::<%= className %>(JSContext* ctx, JSValue value, ExceptionState& exception_state): <%= className %>() {
  FillMembersWithQJSObject(ctx, value, exception_state);
}

bool <%= className %>::FillQJSObjectWithMembers(JSContext* ctx, JSValue qjs_dictionary) const {
  <% if (object.parent) { %>
  <%= object.parent %>::FillQJSObjectWithMembers(ctx, qjs_dictionary);
  <% } %>

  if (!JS_IsObject(qjs_dictionary)) {
    return false;
  }

  <% _.forEach(props, function(prop, index) { %>
  JS_SetPropertyStr(ctx, qjs_dictionary, "<%= prop.name %>_", Converter<<%= generateIDLTypeConverter(prop.type) %>>::ToValue(ctx, <%= prop.name %>_));
  <% }); %>

  return true;
}

void <%= className %>::FillMembersWithQJSObject(JSContext* ctx, JSValue value, ExceptionState& exception_state) {
  <% if (object.parent) { %>
  <%= object.parent %>::FillMembersWithQJSObject(ctx, value, exception_state);
  <% } %>

  if (!JS_IsObject(value)) {
    return;
  }

  <% _.forEach(props, function(prop, index) { %>
  {
      JSValue v = JS_GetPropertyStr(ctx, value, "<%= prop.name %>");
      <%= prop.name %>_ = Converter<<%= generateIDLTypeConverter(prop.type) %>>::FromValue(ctx, v, exception_state);
      JS_FreeValue(ctx, v);
  }

  <% }); %>


}
