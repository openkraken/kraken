
<% if (object.parent) { %>
#include "qjs_<%= _.snakeCase(object.parent) %>.h"
<% } %>

namespace kraken {

class ExecutingContext;
class ExceptionState;

class <%= className %> : public <%= object.parent ? object.parent : 'DictionaryBase' %> {
 public:
  using ImplType = std::shared_ptr<<%= className %>>;
  static std::shared_ptr<<%= className %>> Create();
  static std::shared_ptr<<%= className %>> Create(JSContext* ctx, JSValue value, ExceptionState& exception_state);
  explicit <%= className %>();
  explicit <%= className %>(JSContext* ctx, JSValue value, ExceptionState& exception_state);

  <% _.forEach(props, (function(prop, index) { %>
  <%= generateTypeValue(prop.type) %> <%= prop.name %>() const { return <%= prop.name %>_; }
  void set<%= prop.name[0].toUpperCase() + prop.name.slice(1) %>(<%= generateTypeValue(prop.type) %> value) { <%= prop.name %>_ = value; }
  <% })); %>
  bool FillQJSObjectWithMembers(JSContext *ctx, JSValue qjs_dictionary) const override;
  void FillMembersWithQJSObject(JSContext* ctx, JSValue value, ExceptionState& exception_state);
private:
  <% _.forEach(props, (function(prop, index) { %>
  <%= generateTypeValue(prop.type) %> <%= prop.name %>_;
  <% })); %>
};

}
