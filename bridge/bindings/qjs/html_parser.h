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
  explicit HTMLParser(std::unique_ptr<JSContext> &context);
  bool parseHTML(const char *code, size_t codeLength);

private:
  std::unique_ptr<JSContext> &m_context;
  JSExceptionHandler m_handler;
  void traverseHTML(GumboNode *node, ElementInstance *element);
  void parseProperty(ElementInstance *element, GumboElement *gumboElement);
};
} // namespace kraken::binding::qjs

#endif // KRAKENBRIDGE_HTML_PARSER_H
