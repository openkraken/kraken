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

HTMLParser* HTMLParser::m_instance;

void HTMLParser::parseProperty(JSContext* context, ElementInstance *element,
                               GumboElement *gumboElement) {
  GumboVector *attributes = &gumboElement->attributes;
  for (int j = 0; j < attributes->length; ++j) {
    GumboAttribute *attribute = (GumboAttribute *)attributes->data[j];

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
      JSValueRef styleRef = JSObjectGetProperty(context->context(), element->object, propertyName, nullptr);
      JSObjectRef style = JSValueToObject(context->context(), styleRef, nullptr);
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

          styleDeclarationInstance->internalSetProperty(
            styleKey, JSValueMakeString(context->context(), JSStringCreateWithUTF8CString(styleValue.c_str())),
            nullptr);
        }
      }
    } else {
      std::string strName = attribute->name;
      std::transform(strName.begin(), strName.end(), strName.begin(), ::tolower);
      std::string strValue = attribute->value;
      std::transform(strValue.begin(), strValue.end(), strValue.begin(), ::tolower);
      JSValueRef valueRef = JSValueMakeString(context->context(), JSStringCreateWithUTF8CString(strValue.c_str()));

      // Set property.
      if (!element->setProperty(strName, valueRef, nullptr)) {
        // Set attributes.
        JSStringRef attributesName = JSStringCreateWithUTF8CString("attributes");
        JSValueRef attributesRef = JSObjectGetProperty(context->context(), element->object, attributesName, nullptr);
        JSObjectRef attributes = JSValueToObject(context->context(), attributesRef, nullptr);
        auto attributesInstance = static_cast<JSElementAttributes *>(JSObjectGetPrivate(attributes));
        attributesInstance->setProperty(strName, valueRef, nullptr);
        JSStringRelease(attributesName);
      }
    }
  }
}

void HTMLParser::traverseHTML(JSContext* context, GumboNode *node,
                              NodeInstance *rootNode) {
  const GumboVector *children = &node->v.element.children;
  for (int i = 0; i < children->length; ++i) {
    GumboNode *child = (GumboNode *)children->data[i];

    if (child->type == GUMBO_NODE_ELEMENT) {
      std::string tagName = gumbo_normalized_tagname(child->v.element.tag);
      auto newElement = JSElement::buildElementInstance(context, tagName);
      rootNode->internalAppendChild(newElement);
      parseProperty(context, newElement, &child->v.element);
      // eval javascript when <script>//code...</script>.
      if (child->v.element.tag == GUMBO_TAG_SCRIPT && child->v.element.children.length > 0) {
        JSStringRef jsCode =
          JSStringCreateWithUTF8CString(((GumboNode *)child->v.element.children.data[0])->v.text.text);
        JSEvaluateScript(context->context(), jsCode, nullptr, nullptr, 0, nullptr);
      }

      // Avoid creating a large number of textNode in script Element.
      if (child->v.element.tag != GUMBO_TAG_SCRIPT) {
        traverseHTML(context, child, newElement);
      }
    } else if (child->type == GUMBO_NODE_TEXT) {
      auto newTextNodeInstance = new JSTextNode::TextNodeInstance(JSTextNode::instance(context),
                                                                  JSStringCreateWithUTF8CString(child->v.text.text));
      rootNode->internalAppendChild(newTextNodeInstance);
    }
  }
}

bool HTMLParser::parseHTML(JSContext* context, JSStringRef sourceRef,
                           NodeInstance *rootNode) {
  std::string html = JSStringToStdString(sourceRef);

  if (rootNode != nullptr) {
    // Remove all childNode.
    for (auto iter : rootNode->childNodes) {
      rootNode->internalRemoveChild(iter, nullptr);
    }

    if (trim(html) != "") {
      // Gumbo-parser parse HTML.
      int html_length = html.length();
      GumboOutput *htmlTree = gumbo_parse_with_options(&kGumboDefaultOptions, html.c_str(), html_length);
      traverseHTML(context, htmlTree->root, rootNode);
    }
  } else {
    KRAKEN_LOG(ERROR) << "Root node is null.";
  }

  return true;
}

} // namespace kraken::binding::jsc
