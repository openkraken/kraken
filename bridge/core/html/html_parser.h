/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HTML_PARSER_H
#define KRAKENBRIDGE_HTML_PARSER_H

#include "foundation/native_string.h"
#include "third_party/gumbo-parser/src/gumbo.h"

namespace kraken {

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
}  // namespace kraken

#endif  // KRAKENBRIDGE_HTML_PARSER_H
