// Generated from template:
//   code_generator/src/json/templates/make_names.h.tmpl
// and input files:
//   <%= template_path %>

#include "<%= name %>.h"

namespace kraken {
namespace <%= name %> {

void* names_storage[kNamesCount * ((sizeof(AtomicString) + sizeof(void *) - 1) / sizeof(void *))];

<% _.forEach(data, function(name, index) { %>
<% if (_.isArray(name)) { %>
const AtomicString& k<%= name[0] %> = reinterpret_cast<AtomicString*>(&names_storage)[<%= index %>];
<% } else { %>
const AtomicString& k<%= name[0].toUpperCase() + name.slice(1) %> = reinterpret_cast<AtomicString*>(&names_storage)[<%= index %>];
<% } %>
<% }) %>

void Init() {
  static bool is_loaded = false;
  if (is_loaded) return;
  is_loaded = true;

  struct NameEntry {
    JSAtom atom;
  };

  static const NameEntry kNames[] = {
      <% _.forEach(data, function(name) { %>{ JS_ATOM_<%= name[0] %> },
      <% }); %>
  };

  for(size_t i = 0; i < std::size(kNames); i ++) {
    void* address = reinterpret_cast<AtomicString*>(&names_storage) + i;
    new (address) AtomicString(kNames[i].atom);
  }
};

}
} // kraken
