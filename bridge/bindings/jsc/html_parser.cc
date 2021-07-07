/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_parser.h"
#include "bindings/jsc/DOM/text_node.h"
#include "third_party/gumbo-parser/src/gumbo.h"
#include <unordered_map>
#include <vector>

namespace kraken::binding::jsc {

std::unique_ptr<HTMLParser> createHTMLParser(std::unique_ptr<JSContext> &context, const JSExceptionHandler &handler, void *owner) {
  return std::make_unique<HTMLParser>(context, handler, owner);
}

HTMLParser::HTMLParser(std::unique_ptr<JSContext> &context, const JSExceptionHandler &handler, void *owner)
  : m_context(context), _handler(handler), owner(owner) {

}

void HTMLParser::traverseHTML(GumboNode * node, ElementInstance* element) {
  const GumboVector* children = &node->v.element.children;
  for (int i = 0; i < children->length; ++i) {
    GumboNode* child =(GumboNode*) children->data[i];
    if (child->type == GUMBO_NODE_ELEMENT) {
      auto newElement = JSElement::buildElementInstance(m_context.get(), gumbo_normalized_tagname(child->v.element.tag));
      element->internalAppendChild(newElement);
      traverseHTML(child, newElement);
    } else if (child->type == GUMBO_NODE_TEXT) {
      auto newTextNodeInstance = new JSTextNode::TextNodeInstance(JSTextNode::instance(m_context.get()),
                                                                  JSStringCreateWithUTF8CString(child->v.text.text));
      element->internalAppendChild(newTextNodeInstance);
    }
  }
}

bool HTMLParser::parseHTML(const uint16_t *code, size_t codeLength) {
  ElementInstance* body;
  auto document = DocumentInstance::instance(m_context.get());
  for (int i = 0; i < document->documentElement->childNodes.size(); ++i) {
    NodeInstance* node = document->documentElement->childNodes[i];
    ElementInstance* element = reinterpret_cast<ElementInstance *>(node);


    if (element->tagName() == "BODY") {
      body = element;
      break;
    }
  }

  if (body != nullptr) {
    JSStringRef sourceRef = JSStringCreateWithCharacters(code, codeLength);

    std::string html = JSStringToStdString(sourceRef);

    int html_length = html.length();
    GumboOutput* output = gumbo_parse_with_options(
      &kGumboDefaultOptions, html.c_str(), html_length);

    const GumboVector *root_children = &output->root->v.element.children;

    for (int i = 0; i < root_children->length; ++i) {
      GumboNode* child =(GumboNode*) root_children->data[i];
      if (child->v.element.tag == GUMBO_TAG_BODY) {
        traverseHTML(child, body);
      }
    }

    JSStringRelease(sourceRef);
  } else {
    KRAKEN_LOG(ERROR) << "BODY is null.";
  }

  return true;
}

}


