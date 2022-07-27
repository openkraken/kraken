/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_HTML_PARSER_H
#define BRIDGE_HTML_PARSER_H

#include "bindings/qjs/dom/element.h"
#include "executing_context.h"
#include "include/webf_bridge.h"
#include "third_party/gumbo-parser/src/gumbo.h"

namespace webf::binding::qjs {

class HTMLParser {
 public:
  static bool parseHTML(const char* code, size_t codeLength, NodeInstance* rootNode);
  static bool parseHTML(std::string html, NodeInstance* rootNode);
  static bool parseHTMLFragment(const char* code, size_t codeLength, NodeInstance* rootNode);

 private:
  ExecutionContext* m_context;
  static void traverseHTML(NodeInstance* root, GumboNode* node);
  static void parseProperty(ElementInstance* element, GumboElement* gumboElement);

  static bool parseHTML(std::string html, NodeInstance* rootNode, bool isHTMLFragment);
};
}  // namespace webf::binding::qjs

#endif  // BRIDGE_HTML_PARSER_H
