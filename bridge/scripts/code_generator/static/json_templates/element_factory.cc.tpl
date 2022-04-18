/*
 * Copyright (C) 2021-present The Kraken authors. All rights reserved.
 */

 // Generated from template:
 //   code_generator/src/json/templates/element_factory.cc.tmp
 // and input files:
 //   <%= template_path %>

#include "html_element_factory.h"
#include <unordered_map>
#include "html_names.h"
#include "bindings/qjs/garbage_collected.h"

<% _.forEach(data, (item, index) => { %>
  <% if (_.isString(item)) { %>
#include "core/html/html_<%= item %>_element.h"
  <% } else if (_.isObject(item)) { %>
    <% if (item.interfaceHeaderDir) { %>
#include "<%= item.interfaceHeaderDir %>/html_<%= item.filename ? item.filename : item.name  %>_element.h"
    <% } else if (item.interfaceName != 'HTMLElement'){ %>
#include "core/html/<%= item.filename ? item.filename : `html_${item.name}_element` %>.h"
    <% } %>
  <% } %>
<% }); %>


namespace kraken {

using HTMLConstructorFunction = HTMLElement* (*)(Document&);

using HTMLFunctionMap = std::unordered_map<AtomicString, HTMLConstructorFunction, AtomicString::KeyHasher>;

static HTMLFunctionMap* g_html_constructors = nullptr;

struct CreateHTMLFunctionMapData {
  const AtomicString& tag;
  HTMLConstructorFunction func;
};


<% _.forEach(data, (item, index) => { %>
  <% if (_.isString(item)) { %>

static HTMLElement* HTML<%= item[0].toUpperCase() + item.slice(1) %>Constructor(Document& document) {
  return MakeGarbageCollected<HTML<%= item[0].toUpperCase() + item.slice(1) %>Element>(document);
}
  <% } else if (_.isObject(item)) { %>
    <% if (item.interfaceName) { %>
static HTMLElement* HTML<%= item.name[0].toUpperCase() + item.name.slice(1) %>Constructor(Document& document) {
  return MakeGarbageCollected<<%= item.interfaceName %>>(document);
}
    <% } else { %>
static HTMLElement* HTML<%= item.name[0].toUpperCase() + item.name.slice(1) %>Constructor(Document& document) {
  return MakeGarbageCollected<HTML<%= item.name[0].toUpperCase() + item.name.slice(1) %>Element>(document);
}
    <% } %>
  <% } %>
<% }); %>

static void CreateHTMLFunctionMap() {
  assert(!g_html_constructors);
  g_html_constructors = new HTMLFunctionMap();
  // Empty array initializer lists are illegal [dcl.init.aggr] and will not
  // compile in MSVC. If tags list is empty, add check to skip this.

  static const CreateHTMLFunctionMapData data[] = {

<% _.forEach(data, (item, index) => { %>
  <% if (_.isString(item)) { %>
      {html_names::k<%= item %>, HTML<%= item[0].toUpperCase() + item.slice(1) %>Constructor},
  <% } else if (_.isObject(item)) { %>
    <% if (item.interfaceName) { %>
      {html_names::k<%= item.name %>, HTML<%= item.name[0].toUpperCase() + item.name.slice(1) %>Constructor},
    <% } else { %>
      {html_names::k<%= item.name %>, HTML<%= item.name[0].toUpperCase() + item.name.slice(1) %>Constructor},
    <% } %>
  <% } %>
<% }); %>

  };

  for (size_t i = 0; i < std::size(data); i++)
    g_html_constructors->insert(std::make_pair(data[i].tag, data[i].func));
}

HTMLElement* HTMLElementFactory::Create(const AtomicString& name, Document& document) {
  if (!g_html_constructors)
    CreateHTMLFunctionMap();
  auto it = g_html_constructors->find(name);
  if (it == g_html_constructors->end())
    return nullptr;
  HTMLConstructorFunction function = it->second;
  return function(document);
}

void HTMLElementFactory::Dispose() {
  delete g_html_constructors;
}

}  // namespace kraken
