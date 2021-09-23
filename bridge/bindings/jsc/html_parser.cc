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

void HTMLParser::parseProperty(ElementInstance* element, GumboElement * gumboElement) {
  GumboVector * attributes = &gumboElement->attributes;
  for (int j = 0; j < attributes->length; ++j) {
    GumboAttribute* attribute = (GumboAttribute*) attributes->data[j];

    if (strcmp(attribute->name, "style") == 0) {
      std::vector<std::string> arrStyles;
      std::string::size_type prev_pos = 0, pos = 0;
      std::string strStyles = attribute->value;

      while ((pos = strStyles.find(";", pos)) != std::string::npos) {
        arrStyles.push_back(strStyles.substr(prev_pos, pos - prev_pos));
        prev_pos = ++pos;
      }
      arrStyles.push_back(strStyles.substr(prev_pos, pos - prev_pos));

      JSStringRef propertyName = JSStringCreateWithUTF8CString("style");
      JSValueRef styleRef = JSObjectGetProperty(m_context->context(), element->object, propertyName, nullptr);
      JSObjectRef style = JSValueToObject(m_context->context(), styleRef, nullptr);
      auto styleDeclarationInstance = static_cast<StyleDeclarationInstance *>(JSObjectGetPrivate(style));
      JSStringRelease(propertyName);

      for (auto s : arrStyles) {
        std::string::size_type position = s.find(":");
        if (position != s.npos) {
          std::string styleKey = s.substr(0, position);
          std::transform(styleKey.begin(), styleKey.end(), styleKey.begin(), ::tolower);
          trim(styleKey);

          std::string styleValue = s.substr(position + 1, s.length());
          std::transform(styleValue.begin(), styleValue.end(), styleValue.begin(), ::tolower);
          trim(styleValue);

          styleDeclarationInstance->internalSetProperty(styleKey, JSValueMakeString(m_context->context() ,JSStringCreateWithUTF8CString(styleValue.c_str())), nullptr);
        }
      }
    } else {
      std::string strName = attribute->name;
      std::transform(strName.begin(), strName.end(), strName.begin(), ::tolower);
      std::string strValue = attribute->value;
      std::transform(strValue.begin(), strValue.end(), strValue.begin(), ::tolower);
      JSValueRef valueRef = JSValueMakeString(m_context->context(), JSStringCreateWithUTF8CString(strValue.c_str()));
    }
  }
}

void HTMLParser::traverseHTML(GumboNode * node, ElementInstance* element) {
  const GumboVector* children = &node->v.element.children;
  for (int i = 0; i < children->length; ++i) {
    GumboNode* child = (GumboNode*) children->data[i];

    if (child->type == GUMBO_NODE_ELEMENT) {
      std::string tagName = gumbo_normalized_tagname(child->v.element.tag);
      auto newElement = JSElement::buildElementInstance(m_context.get(), tagName);
      element->internalAppendChild(newElement);
      parseProperty(newElement, &child->v.element);

      // eval javascript when <script>//code...</script>.
      if (child->v.element.tag == GUMBO_TAG_SCRIPT && child->v.element.children.length > 0) {
        JSStringRef jsCode = JSStringCreateWithUTF8CString(((GumboNode*) child->v.element.children.data[0])->v.text.text);
        JSEvaluateScript(m_context->context(), jsCode, nullptr, nullptr, 0, nullptr);
      }

      // Avoid creating a large number of textNode in script Element.
      if (child->v.element.tag != GUMBO_TAG_SCRIPT) {
        traverseHTML(child, newElement);
      }
    } else if (child->type == GUMBO_NODE_TEXT) {
      auto newTextNodeInstance = new JSTextNode::TextNodeInstance(JSTextNode::instance(m_context.get()),
                                                                  JSStringCreateWithUTF8CString(child->v.text.text));
      element->internalAppendChild(newTextNodeInstance);
    }
  }
}

bool HTMLParser::parseHTML(const uint16_t *code, size_t codeLength) {
  // gumbo-parser parse HTML.
  JSStringRef sourceRef = JSStringCreateWithCharacters(code, codeLength);
  std::string html = JSStringToStdString(sourceRef);
  int html_length = html.length();
  GumboOutput* htmlTree = gumbo_parse_with_options(
    &kGumboDefaultOptions, html.c_str(), html_length);

  const GumboVector *root_children = &htmlTree->root->v.element.children;

  // find body.
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


