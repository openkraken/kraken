/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "html_parser.h"
#include "dom/document.h"
#include "dom/text_node.h"

#include <utility>

namespace kraken::binding::qjs {

HTMLParser::HTMLParser(std::unique_ptr<JSContext> &context)
  : m_context(context) {
}

inline std::string trim(std::string &str) {
  str.erase(0, str.find_first_not_of(' ')); // prefixing spaces
  str.erase(str.find_last_not_of(' ') + 1); // surfixing spaces
  return str;
}

bool HTMLParser::parseHTML(const char *code, size_t codeLength) {
  GumboOutput* htmlTree = gumbo_parse_with_options(&kGumboDefaultOptions, code, codeLength);

  const GumboVector *root_children = &htmlTree->root->v.element.children;

  // find body.
  ElementInstance *body = nullptr;
  auto document = DocumentInstance::instance(Document::instance(m_context.get()));
  int32_t documentElementsChildNodesLen = arrayGetLength(m_context->ctx(), document->documentElement()->childNodes);
  for (int i = 0; i < documentElementsChildNodesLen; i ++) {
    JSValue n = JS_GetPropertyUint32(m_context->ctx(), document->documentElement()->childNodes, i);
    auto *node = static_cast<NodeInstance *>(JS_GetOpaque(n, Node::classId(n)));
    auto* element = reinterpret_cast<ElementInstance *>(node);

    if (element->tagName() == "BODY") {
      body = element;
      JS_FreeValue(m_context->ctx(), n);
      break;
    }
    JS_FreeValue(m_context->ctx(), n);
  }

  if (body != nullptr) {
    for (int i = 0; i < root_children->length; ++i) {
      auto* child =(GumboNode*) root_children->data[i];
      if (child->v.element.tag == GUMBO_TAG_BODY) {
        traverseHTML(child, body);
      }
    }
  } else {
    KRAKEN_LOG(ERROR) << "BODY is null.";
  }

  return true;
}
void HTMLParser::traverseHTML(GumboNode *node, ElementInstance *element) {
  const GumboVector* children = &node->v.element.children;
  for (int i = 0; i < children->length; ++i) {
    auto* child = (GumboNode*) children->data[i];

    if (child->type == GUMBO_NODE_ELEMENT) {
      std::string tagName = gumbo_normalized_tagname(child->v.element.tag);
      JSValue constructor = Element::getConstructor(m_context.get(), tagName);

      JSValue tagNameValue = JS_NewString(m_context->ctx(), tagName.c_str());
      JSValue argv[] = {
        tagNameValue
      };
      JSValue newElementValue = JS_CallConstructor(m_context->ctx(), constructor, 1, argv);
      JS_FreeValue(m_context->ctx(), tagNameValue);
      auto *newElementInstance = static_cast<ElementInstance *>(JS_GetOpaque(newElementValue, Element::classId()));
      element->internalAppendChild(newElementInstance);
      parseProperty(newElementInstance, &child->v.element);

      // eval javascript when <script>//code...</script>.
      if (child->v.element.children.length > 0) {
        if (child->v.element.tag == GUMBO_TAG_SCRIPT) {
          const char* code = ((GumboNode*) child->v.element.children.data[0])->v.text.text;
          m_context->evaluateJavaScript(code, strlen(code), "vm://", 0);
        } else {
          traverseHTML(child, newElementInstance);
        }
      }

      JS_FreeValue(m_context->ctx(), newElementValue);
    } else if (child->type == GUMBO_NODE_TEXT) {

      JSValue textContentValue = JS_NewString(m_context->ctx(), child->v.text.text);
      JSValue argv[] = {
        textContentValue
      };
      JSValue textNodeValue = JS_CallConstructor(m_context->ctx(), TextNode::instance(m_context.get())->classObject, 1, argv);
      JS_FreeValue(m_context->ctx(), textContentValue);

      auto *textNodeInstance = static_cast<TextNodeInstance *>(JS_GetOpaque(textNodeValue, TextNode::classId()));
      element->internalAppendChild(textNodeInstance);
      JS_FreeValue(m_context->ctx(), textNodeValue);
    }
  }
}
void HTMLParser::parseProperty(ElementInstance *element, GumboElement *gumboElement) {
  GumboVector * attributes = &gumboElement->attributes;
  for (int j = 0; j < attributes->length; ++j) {
    auto* attribute = (GumboAttribute*) attributes->data[j];

    if (strcmp(attribute->name, "style") == 0) {
      std::vector<std::string> arrStyles;
      std::string::size_type prev_pos = 0, pos = 0;
      std::string strStyles = attribute->value;

      while ((pos = strStyles.find(';', pos)) != std::string::npos) {
        arrStyles.push_back(strStyles.substr(prev_pos, pos - prev_pos));
        prev_pos = ++pos;
      }
      arrStyles.push_back(strStyles.substr(prev_pos, pos - prev_pos));

      auto *style = element->style();

      for (auto &s : arrStyles) {
        std::string::size_type position = s.find(':');
        if (position != std::basic_string<char>::npos) {
          std::string styleKey = s.substr(0, position);
          std::transform(styleKey.begin(), styleKey.end(), styleKey.begin(), ::tolower);
          trim(styleKey);

          std::string styleValue = s.substr(position + 1, s.length());
          std::transform(styleValue.begin(), styleValue.end(), styleValue.begin(), ::tolower);
          trim(styleValue);

          JSValue newStyleValue = JS_NewString(m_context->ctx(), styleValue.c_str());
          style->internalSetProperty(styleKey, newStyleValue);
          JS_FreeValue(m_context->ctx(), newStyleValue);
        }
      }

    } else {
      std::string strName = attribute->name;
      std::transform(strName.begin(), strName.end(), strName.begin(), ::tolower);
      std::string strValue = attribute->value;
      std::transform(strValue.begin(), strValue.end(), strValue.begin(), ::tolower);

      JSAtom key = JS_NewAtom(m_context->ctx(), strName.c_str());
      JSValue value = JS_NewString(m_context->ctx(), strValue.c_str());

      JS_SetProperty(m_context->ctx(), element->instanceObject, key, value);
      JS_FreeAtom(m_context->ctx(), key);
    }
  }

}

} // namespace kraken::binding::qjs
