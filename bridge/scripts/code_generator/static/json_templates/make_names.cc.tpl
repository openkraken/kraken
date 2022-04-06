// Generated from template:
//   code_generator/src/json/templates/make_names.h.tmpl
// and input files:
//   <%= template_path %>

#include "<%= name %>.h"

namespace kraken {
namespace <%= name %> {

void* names_storage[kNamesCount * ((sizeof(AtomicString) + sizeof(void *) - 1) / sizeof(void *))];

<% _.forEach(data, function(name, index) { %><% if (_.isArray(name)) { %>const AtomicString& k<%= name[0] %> = reinterpret_cast<AtomicString*>(&names_storage)[<%= index %>];
<% } else { %>const AtomicString& k<%= name %> = reinterpret_cast<AtomicString*>(&names_storage)[<%= index %>];<% } %>
<% }) %>

void Init(JSContext* ctx) {
  struct NameEntry {
     const char* str;
   };

  static const NameEntry kNames[] = {
      <% _.forEach(data, function(name) { %><% if (Array.isArray(name)) { %>{ "<%= name[0] %>" },<% } else { %>{ "<%= name %>" },<% } %>
      <% }); %>
  };

  for(size_t i = 0; i < std::size(kNames); i ++) {
    void* address = reinterpret_cast<AtomicString*>(&names_storage) + i;
    new (address) AtomicString(ctx, kNames[i].str);
  }
};

void Dispose(){
  for(size_t i = 0; i < kNamesCount; i ++) {
    AtomicString* atomic_string = reinterpret_cast<AtomicString*>(&names_storage) + i;
    atomic_string->~AtomicString();
  }
};


}
} // kraken
