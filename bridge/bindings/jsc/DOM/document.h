/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_DOCUMENT_H
#define KRAKENBRIDGE_DOCUMENT_H

#include "bindings/jsc/js_context.h"
#include "bindings/jsc/macros.h"
#include "element.h"
#include "node.h"

namespace kraken::binding::jsc {

struct NativeDocument;

class JSDocument : public JSNode {
public:
  static JSDocument *instance(JSContext *context);

  static JSElement *getElementOfTagName(JSContext *context, std::string &tagName);

  static JSValueRef createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef createTextNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef createComment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);


  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  class DocumentInstance : public NodeInstance {
  public:
    enum class DocumentProperty {
      kCreateElement,
      kBody,
      kCreateTextNode,
      kCreateComment,
      kNodeName,
    };
    static std::array<JSStringRef, 4> &getDocumentPropertyNames();
    static const std::unordered_map<std::string, DocumentProperty> &getPropertyMap();

    DocumentInstance() = delete;
    explicit DocumentInstance(JSDocument *document);
    ~DocumentInstance();
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

    NativeDocument *nativeDocument;

  private:
    JSObjectRef body;
    JSObjectRef _createElement {nullptr};
    JSObjectRef _createTextNode {nullptr};
    JSObjectRef _createComment {nullptr};
  };

protected:
  JSDocument() = delete;
  JSDocument(JSContext *context);
};

struct NativeDocument {
  NativeDocument() = delete;
  explicit NativeDocument(NativeNode *nativeNode) : nativeNode(nativeNode) {};

  NativeNode *nativeNode;
};

void bindDocument(std::unique_ptr<JSContext> &context);

} // namespace kraken::binding::jsc

#endif // KRAKENBRIDGE_DOCUMENT_H
