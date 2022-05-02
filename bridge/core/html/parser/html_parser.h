/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_HTML_PARSER_H
#define KRAKENBRIDGE_HTML_PARSER_H

#include <string>
#include <third_party/gumbo-parser/src/gumbo.h>
#include "foundation/native_string.h"

namespace kraken {

class Node;
class Element;
class ExecutingContext;

class HTMLParser {
 public:
  static bool parseHTML(const char* code, size_t codeLength, Node* rootNode);
  static bool parseHTML(const std::string& html, Node* rootNode);
  static bool parseHTMLFragment(const char* code, size_t codeLength, Node* rootNode);

 private:
  ExecutingContext* context_;
  static void traverseHTML(Node* root, GumboNode* node);
  static void parseProperty(Element* element, GumboElement* gumboElement);

  static bool parseHTML(const std::string& html, Node* rootNode, bool isHTMLFragment);
};
}  // namespace kraken

#endif  // KRAKENBRIDGE_HTML_PARSER_H
