// Generated from template:
//   code_generator/src/json/templates/make_names.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef <%= _.snakeCase(name).toUpperCase() %>_H_
#define <%= _.snakeCase(name).toUpperCase() %>_H_

#include "bindings/qjs/atom_string.h"

namespace kraken {
namespace <%= name %> {

<% _.forEach(data, function(name, index) { %><% if (_.isArray(name)) { %>extern const AtomicString& k<%= name[0] %>;
<% } else { %>extern const AtomicString& k<%= name %>;
<% } %><% }) %>

constexpr unsigned kNamesCount = <%= data.length %>;

void Init(JSContext* ctx);
void Dispose();

}

} // kraken

#endif  // #define <%= _.snakeCase(name).toUpperCase() %>
