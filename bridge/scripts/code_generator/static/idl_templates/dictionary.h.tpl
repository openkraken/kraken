#include "bindings/qjs/converter_impl.h"

<% if (object.parent) { %>
#include "qjs_<%= _.snakeCase(object.parent) %>.h"
<% } %>

namespace kraken {

class ExecutingContext;

class <%= className %> : public <%= object.parent ? object.parent : 'DictionaryBase' %> {
 public:
  static std::shared_ptr<<%= className %>> Create();
  static std::shared_ptr<<%= className %>> Create(JSContext* ctx, JSValue value, ExceptionState& exception_state);
  explicit <%= className %>();
  explicit <%= className %>(JSContext* ctx, JSValue value, ExceptionState& exception_state);

  <% _.forEach(props, (function(prop, index) { %>
  Converter<<%= generateTypeConverter(prop.type) %>>::ImplType <%= prop.name %>() const { return <%= prop.name %>_; }
  void set<%= prop.name[0].toUpperCase() + prop.name.slice(1) %>(Converter<<%= generateTypeConverter(prop.type) %>>::ImplType value) { <%= prop.name %>_ = value; }
  <% })); %>
private:
  bool FillQJSObjectWithMembers(JSContext *ctx, JSValue qjs_dictionary) const override;
  void FillMembersWithQJSObject(JSContext* ctx, JSValue value, ExceptionState& exception_state);
  <% _.forEach(props, (function(prop, index) { %>
  Converter<<%= generateTypeConverter(prop.type) %>>::ImplType <%= prop.name %>_;
  <% })); %>
};

}
