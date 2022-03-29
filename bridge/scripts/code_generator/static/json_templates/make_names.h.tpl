// Generated from template:
//   code_generator/src/json/templates/make_names.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef <%= _.snakeCase(name).toUpperCase() %>_H_
#define <%= _.snakeCase(name).toUpperCase() %>_H_

#include "bindings/qjs/atom_string.h"

namespace kraken {

<% _.forEach(data, function(name, index) { %>
extern const AtomicString& k<%= name[0].toUpperCase() + name.slice(1) %>;
<% }) %>

constexpr unsigned kNamesCount = <%= data.length %>;

void Init();

} // kraken

#endif  // #define <%= _.snakeCase(name).toUpperCase() %>
