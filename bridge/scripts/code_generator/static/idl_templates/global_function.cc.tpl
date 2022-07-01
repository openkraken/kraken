static JSValue ${object.declare.name}(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  <%= generateFunctionBody(blob, object.declare) %>
}
