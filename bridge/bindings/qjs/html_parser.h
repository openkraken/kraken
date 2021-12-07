/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HTML_PARSER_H
#define KRAKENBRIDGE_HTML_PARSER_H

#include "bindings/qjs/dom/element.h"
#include "include/kraken_bridge.h"
#include "js_context.h"
#include "third_party/gumbo-parser/src/gumbo.h"

namespace kraken::binding::qjs {

class HTMLParser {
 public:
  static bool parseHTML(const char* code, size_t codeLength, NodeInstance* rootNode);
  static bool parseHTML(std::string html, NodeInstance* rootNode);

 private:
  JSContext* m_context;
  static void traverseHTML(NodeInstance* root, GumboNode* node);
  static void parseProperty(ElementInstance* element, GumboElement* gumboElement);
};
}  // namespace kraken::binding::qjs

#endif  // KRAKENBRIDGE_HTML_PARSER_H
