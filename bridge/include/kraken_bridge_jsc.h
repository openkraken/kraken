/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_BRIDGE_JSC_H
#define KRAKEN_BRIDGE_JSC_H

// MUST READ:
// All the struct which prefix with NativeXXX struct (exp: NativeElement) has a corresponding struct in Dart code.
// All struct members include variables and functions must be follow the same order with Dart class, to keep the same memory layout cross dart and C++ code.
#include "kraken_foundation.h"
#include <JavaScriptCore/JavaScript.h>
#include <chrono>
#include <deque>
#include <cassert>
#include <functional>
#include <map>
#include <unordered_map>
#include <vector>
#include <forward_list>
#include "third_party/gumbo-parser/src/gumbo.h"

using JSExceptionHandler = std::function<void(int32_t contextId, const char *errmsg, JSObjectRef error)>;

class NativeString;

namespace kraken::binding::jsc {

class JSContext;
class JSFunctionHolder;
class JSStringHolder;
class JSValueHolder;
class HostObject;
template <typename T> class JSHostObjectHolder;
class HostClass;
class JSEvent;
class EventInstance;
class NativeEvent;
class NativeEventTarget;
class JSEventTarget;
class EventTargetInstance;
class JSNode;
class NodeInstance;
struct NativeNode;
class JSDocument;
class DocumentCookie;
class DocumentInstance;
struct NativeDocument;
class CSSStyleDeclaration;
class JSElementAttributes;
class JSElement;
class JSImageElement;
class ElementInstance;
struct NativeBoundingClientRect;
class BoundingClientRect;
struct NativeElement;
struct NativeImageElement;
class JSEvent;
struct NativeEvent;
class JSGestureEvent;
struct NativeGestureEvent;
class GestureEventInstance;
struct NativeMouseEvent;
class MouseEventInstance;

class JSContext {
public:
  static std::vector<JSStaticFunction> globalFunctions;
  static std::vector<JSStaticValue> globalValue;

  JSContext() = delete;
  JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
  ~JSContext();

  KRAKEN_EXPORT bool evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine);
  KRAKEN_EXPORT bool evaluateJavaScript(const char16_t *code, size_t length, const char *sourceURL, int startLine);

  KRAKEN_EXPORT bool isValid();

  KRAKEN_EXPORT JSObjectRef global();
  KRAKEN_EXPORT JSGlobalContextRef context();

  KRAKEN_EXPORT int32_t getContextId();

  KRAKEN_EXPORT void *getOwner();

  KRAKEN_EXPORT bool handleException(JSValueRef exc);

  KRAKEN_EXPORT void reportError(const char *errmsg);

  std::chrono::time_point<std::chrono::system_clock> timeOrigin;

  int32_t uniqueId;

private:
  int32_t contextId;
  JSExceptionHandler _handler;
  void *owner;
  std::atomic<bool> ctxInvalid_{false};
  JSGlobalContextRef ctx_;
};

class HTMLParser {
public:
  HTMLParser(std::unique_ptr<JSContext> &context, const JSExceptionHandler &handler, void *owner);
  KRAKEN_EXPORT bool parseHTML(const uint16_t *code, size_t codeLength);

private:
  std::unique_ptr<JSContext> &m_context;
  JSExceptionHandler _handler;
  void *owner;

  void traverseHTML(GumboNode * node, ElementInstance* element);

  void parseProperty(ElementInstance* element, GumboElement * gumboElement);
};

class KRAKEN_EXPORT JSFunctionHolder {
public:
  JSFunctionHolder() = delete;
  KRAKEN_EXPORT explicit JSFunctionHolder(JSContext *context, JSObjectRef root, void *data, const std::string &name,
                                          JSObjectCallAsFunctionCallback callback);
  JSObjectRef function();
private:
  JSObjectRef m_function{nullptr};
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(JSFunctionHolder);
};

class KRAKEN_EXPORT JSStringHolder {
public:
  JSStringHolder() = delete;
  explicit JSStringHolder(JSContext *context, const std::string &string);
  ~JSStringHolder();

  JSValueRef makeString();
  JSStringRef getString();
  std::string string();

  const JSChar *ptr();
  size_t utf8Size();
  size_t size();
  bool empty();

  void setString(JSStringRef value);
  void setString(NativeString *value);

private:
  JSContext *m_context;
  JSStringRef m_string{nullptr};
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(JSStringHolder);
};

class KRAKEN_EXPORT JSValueHolder {
public:
  JSValueHolder() = delete;
  explicit JSValueHolder(JSContext *context, JSValueRef value);
  ~JSValueHolder();
  JSValueRef value();
  void setValue(JSValueRef value);

private:
  JSContext *m_context;
  JSValueRef m_value{nullptr};
  KRAKEN_DISALLOW_COPY_ASSIGN_AND_MOVE(JSValueHolder);
};

void KRAKEN_EXPORT buildUICommandArgs(JSStringRef key, NativeString &args_01);
void KRAKEN_EXPORT buildUICommandArgs(std::string &key, NativeString &args_01);
void KRAKEN_EXPORT buildUICommandArgs(std::string &key, JSStringRef value, NativeString &args_01,
                                      NativeString &args_02);
void KRAKEN_EXPORT buildUICommandArgs(std::string &key, std::string &value, NativeString &args_01,
                                      NativeString &args_02);

void KRAKEN_EXPORT throwJSError(JSContextRef ctx, const char *msg, JSValueRef *exception);

KRAKEN_EXPORT NativeString *stringToNativeString(std::string &string);
KRAKEN_EXPORT NativeString *stringRefToNativeString(JSStringRef string);


KRAKEN_EXPORT JSObjectRef makeObjectFunctionWithPrivateData(JSContext *context, void *data, const char *name,
                                                JSObjectCallAsFunctionCallback callback);

KRAKEN_EXPORT JSObjectRef JSObjectMakePromise(JSContext *context, void *data, JSObjectCallAsFunctionCallback callback,
                                  JSValueRef *exception);

KRAKEN_EXPORT std::string JSStringToStdString(JSStringRef jsString);

class HostObject {
public:
  static JSValueRef proxyGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                     JSValueRef *exception);
  static bool proxySetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value,
                               JSValueRef *exception);
  static void proxyGetPropertyNames(JSContextRef ctx, JSObjectRef object, JSPropertyNameAccumulatorRef propertyNames);
  static void proxyFinalize(JSObjectRef obj);

  HostObject() = delete;
  HostObject(JSContext *context, std::string name);
  std::string name;

  JSContext *context;
  int32_t contextId;
  JSObjectRef jsObject;
  JSContextRef ctx;
  // The C++ object's dtor will be called when the GC finalizes this
  // object.  (This may be as late as when the JSContext is shut down.)
  // You have no control over which thread it is called on.  This will
  // be called from inside the GC, so it is unsafe to do any VM
  // operations which require a JSContext&.  Derived classes' dtors
  // should also avoid doing anything expensive.  Calling the dtor on
  // a js object is explicitly ok.  If you want to do JS operations,
  // or any nontrivial work, you should add it to a work queue, and
  // manage it externally.
  virtual ~HostObject();

  // When JS wants a property with a given name from the HostObject,
  // it will call this method.  If it throws an exception, the call
  // will throw a JS \c Error object. By default this returns undefined.
  // \return the value for the property.
  KRAKEN_EXPORT virtual JSValueRef getProperty(std::string &name, JSValueRef *exception);

  // When JS wants to set a property with a given name on the HostObject,
  // it will call this method. If it throws an exception, the call will
  // throw a JS \c Error object. By default this throws a type error exception
  // mimicking the behavior of a frozen object in strict mode.
  KRAKEN_EXPORT virtual bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception);

  KRAKEN_EXPORT virtual void getPropertyNames(JSPropertyNameAccumulatorRef accumulator);

private:
  JSClassRef jsClass;
};

template <typename T> class JSHostObjectHolder {
public:
  JSHostObjectHolder() = delete;
  explicit JSHostObjectHolder(JSContext *context, JSObjectRef root, const char *key, T *hostObject)
    : m_object(hostObject), m_context(context) {
    JSStringHolder keyStringHolder = JSStringHolder(context, key);
    JSObjectSetProperty(context->context(), root, keyStringHolder.getString(), hostObject->jsObject,
                        kJSPropertyAttributeNone, nullptr);
  }
  T *operator*() {
    return m_object;
  }

private:
  T *m_object;
  JSContext *m_context{nullptr};
};

class HostClass {
public:
  static void proxyFinalize(JSObjectRef object);
  static bool proxyHasInstance(JSContextRef ctx, JSObjectRef constructor, JSValueRef possibleInstance,
                               JSValueRef *exception);
  static JSValueRef proxyCallAsFunction(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
  static JSObjectRef proxyCallAsConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                            const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef proxyGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                     JSValueRef *exception);
  static JSValueRef proxyInstanceGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                             JSValueRef *exception);
  static JSValueRef proxyPrototypeGetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName,
                                              JSValueRef *exception);
  static bool proxyInstanceSetProperty(JSContextRef ctx, JSObjectRef object, JSStringRef propertyName, JSValueRef value,
                                       JSValueRef *exception);
  static void proxyInstanceGetPropertyNames(JSContextRef ctx, JSObjectRef object,
                                            JSPropertyNameAccumulatorRef propertyNames);
  static void proxyInstanceFinalize(JSObjectRef obj);

  HostClass() = delete;
  HostClass(JSContext *context, std::string name);
  HostClass(JSContext *context, HostClass *parentHostClass, std::string name, const JSStaticFunction *staticFunction,
            const JSStaticValue *staticValue);

  KRAKEN_EXPORT virtual JSValueRef getProperty(std::string &name, JSValueRef *exception);
  KRAKEN_EXPORT virtual JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception);

  // Triggered when this HostClass had been finalized by GC.
  KRAKEN_EXPORT virtual ~HostClass();

  KRAKEN_EXPORT virtual JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                                        const JSValueRef *arguments, JSValueRef *exception);

  // The instance class represent every javascript instance objects created by new expression.
  class Instance {
  public:
    Instance() = delete;
    KRAKEN_EXPORT explicit Instance(HostClass *hostClass);
    KRAKEN_EXPORT virtual ~Instance();
    KRAKEN_EXPORT virtual JSValueRef getProperty(std::string &name, JSValueRef *exception);
    KRAKEN_EXPORT virtual bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception);
    KRAKEN_EXPORT virtual void getPropertyNames(JSPropertyNameAccumulatorRef accumulator);

    template <typename T> T *prototype() {
      return reinterpret_cast<T *>(_hostClass);
    }

    JSObjectRef object{nullptr};
    HostClass *_hostClass{nullptr};
    JSContext *context{nullptr};
    JSContextRef ctx{nullptr};
    int32_t contextId;
  };

  static bool hasProto(JSContextRef ctx, JSObjectRef child, JSValueRef *exception);
  static JSObjectRef getProto(JSContextRef ctx, JSObjectRef child, JSValueRef *exception);
  static void setProto(JSContextRef ctx, JSObjectRef prototype, JSObjectRef child, JSValueRef *exception);

  std::string _name{""};
  JSContext *context{nullptr};
  int32_t contextId;
  JSContextRef ctx{nullptr};
  // The javascript constructor function.
  JSObjectRef classObject{nullptr};
  // The class template of javascript instance objects.
  JSClassRef instanceClass{nullptr};
  // The prototype object of this class.
  JSObjectRef prototypeObject{nullptr};
  JSObjectRef _call{nullptr};

private:
  // The class template of javascript constructor function.
  JSClassRef jsClass{nullptr};
  HostClass *_parentHostClass{nullptr};
};

class JSHostClassHolder {
public:
  JSHostClassHolder() = delete;
  explicit JSHostClassHolder(JSContext *context, JSObjectRef root, const char *key, HostClass::Instance *hostClass)
    : m_object(hostClass), m_context(context) {
    JSStringHolder keyStringHolder = JSStringHolder(context, key);
    JSObjectSetProperty(context->context(), root, keyStringHolder.getString(), hostClass->object,
                        kJSPropertyAttributeNone, nullptr);
  }
  HostClass::Instance *operator*() {
    return m_object;
  }

private:
  HostClass::Instance *m_object;
  JSContext *m_context{nullptr};
};

using EventCreator = EventInstance *(*)(JSContext *context, void *nativeEvent);

class JSEvent : public HostClass {
public:
  DEFINE_OBJECT_PROPERTY(Event, 10, type, bubbles, cancelable, timestamp, defaultPrevented, target, srcElement,
                         currentTarget, returnValue, cancelBubble)
  DEFINE_PROTOTYPE_OBJECT_PROPERTY(Event, 4, stopImmediatePropagation, stopPropagation, preventDefault, initEvent)

  static std::unordered_map<JSContext *, JSEvent *> instanceMap;
  static std::unordered_map<std::string, EventCreator> eventCreatorMap;
  OBJECT_INSTANCE(JSEvent)
  // Create an Event Object from an nativeEvent address which allocated by dart side.
  static JSValueRef initWithNativeEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef stopPropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef initEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef stopImmediatePropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                             size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef preventDefault(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static EventInstance *buildEventInstance(std::string &eventType, JSContext *context, void *nativeEvent,
                                           bool isCustomEvent);

  static void defineEvent(std::string eventType, EventCreator creator);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSEvent() = delete;
  explicit JSEvent(JSContext *context, const char *name);
  explicit JSEvent(JSContext *context);
  ~JSEvent() override;

private:
  friend EventInstance;
  JSFunctionHolder m_initWithNativeEvent{context, classObject, this, "__initWithNativeEvent__", initWithNativeEvent};
  JSFunctionHolder m_stopImmediatePropagation{context, prototypeObject, this, "stopImmediatePropagation",
                                              stopImmediatePropagation};
  JSFunctionHolder m_stopPropagation{context, prototypeObject, this, "stopPropagation", stopPropagation};
  JSFunctionHolder m_initEvent{context, prototypeObject, this, "initEvent", initEvent};
  JSFunctionHolder m_preventDefault{context, prototypeObject, this, "preventDefault", preventDefault};
};

class EventInstance : public HostClass::Instance {
public:
  EventInstance() = delete;

  explicit EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent);
  explicit EventInstance(JSEvent *jsEvent, std::string eventType, JSValueRef eventInit, JSValueRef *exception);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~EventInstance() override;
  NativeEvent *nativeEvent;
  bool _cancelled{false};
  bool _propagationStopped{false};
  bool _propagationImmediatelyStopped{false};

private:
  friend JSEvent;
};

struct NativeEvent {
  NativeEvent() = delete;
  explicit KRAKEN_EXPORT NativeEvent(NativeString *eventType) : type(eventType){};
  NativeString *type;
  int64_t bubbles{0};
  int64_t cancelable{0};
  int64_t timeStamp{0};
  int64_t defaultPrevented{0};
  // The pointer address of target EventTargetInstance object.
  void *target{nullptr};
  // The pointer address of current target EventTargetInstance object.
  void *currentTarget{nullptr};
};

class JSEventTarget : public HostClass {
public:
  static std::unordered_map<JSContext *, JSEventTarget *> instanceMap;
  static JSEventTarget *instance(JSContext *context);
  DEFINE_OBJECT_PROPERTY(EventTarget, 1, eventTargetId);

  #if defined(IS_TEST)
  DEFINE_PROTOTYPE_OBJECT_PROPERTY(EventTarget, 4, addEventListener, removeEventListener, dispatchEvent,
                                   __kraken_clear_event_listeners__);
  #else
  DEFINE_PROTOTYPE_OBJECT_PROPERTY(EventTarget, 3, addEventListener, removeEventListener, dispatchEvent);
  #endif

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSEventTarget() = delete;
  friend EventTargetInstance;
  KRAKEN_EXPORT explicit JSEventTarget(JSContext *context, const char *name);
  KRAKEN_EXPORT explicit JSEventTarget(JSContext *context, const JSStaticFunction *staticFunction,
                                       const JSStaticValue *staticValue);
  ~JSEventTarget();

private:
  std::vector<std::string> m_jsOnlyEvents;

  static JSValueRef addEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef removeEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef dispatchEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef clearListeners(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  JSFunctionHolder m_removeEventListener{context, prototypeObject, nullptr, "removeEventListener", removeEventListener};
  JSFunctionHolder m_dispatchEvent{context, prototypeObject, nullptr, "dispatchEvent", dispatchEvent};
  JSFunctionHolder m_addEventListener{context, prototypeObject, nullptr, "addEventListener", addEventListener};
  #ifdef IS_TEST
  JSFunctionHolder m_clearListeners{context, prototypeObject, nullptr, "__kraken_clear_event_listeners__", clearListeners};
  #endif
};

class EventTargetInstance : public HostClass::Instance {
public:
  EventTargetInstance() = delete;
  KRAKEN_EXPORT explicit EventTargetInstance(JSEventTarget *eventTarget);
  KRAKEN_EXPORT explicit EventTargetInstance(JSEventTarget *eventTarget, int64_t targetId);
  KRAKEN_EXPORT JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  KRAKEN_EXPORT bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  KRAKEN_EXPORT void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  JSValueRef getPropertyHandler(std::string &name, JSValueRef *exception);
  void setPropertyHandler(std::string &name, JSValueRef value, JSValueRef *exception);
  bool dispatchEvent(EventInstance *event);

  ~EventTargetInstance() override;
  int32_t eventTargetId;
  NativeEventTarget *nativeEventTarget{nullptr};

private:
  friend JSEventTarget;
  // TODO: use std::u16string for better performance.
  std::unordered_map<std::string, std::forward_list<JSObjectRef>> _eventHandlers;
  std::unordered_map<std::string, JSObjectRef> _propertyEventHandler;
  bool internalDispatchEvent(EventInstance *eventInstance);
};

using NativeDispatchEvent = void (*)(NativeEventTarget *nativeEventTarget, NativeString *eventType, void *nativeEvent,
                                     int32_t isCustomEvent);

struct NativeEventTarget {
  NativeEventTarget() = delete;
  NativeEventTarget(EventTargetInstance *_instance)
    : instance(_instance), dispatchEvent(NativeEventTarget::dispatchEventImpl){};

  KRAKEN_EXPORT static void dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeString *eventType,
                                              void *nativeEvent, int32_t isCustomEvent);

  EventTargetInstance *instance;
  NativeDispatchEvent dispatchEvent;
};

enum NodeType {
  ELEMENT_NODE = 1,
  TEXT_NODE = 3,
  COMMENT_NODE = 8,
  DOCUMENT_NODE = 9,
  DOCUMENT_TYPE_NODE = 10,
  DOCUMENT_FRAGMENT_NODE = 11
};

class JSNode : public JSEventTarget {
public:
  static std::unordered_map<JSContext *, JSNode *> instanceMap;
  static JSNode *instance(JSContext *context);
  DEFINE_OBJECT_PROPERTY(Node, 10, isConnected, ownerDocument, firstChild, lastChild, parentNode, childNodes, previousSibling,
                         nextSibling, nodeType, textContent);
  DEFINE_PROTOTYPE_OBJECT_PROPERTY(Node, 6, appendChild, remove, removeChild, insertBefore, replaceChild, cloneNode);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  static JSValueRef cloneNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef appendChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception);
  /**
   * The ChildNode.remove() method removes the object
   * from the tree it belongs to.
   * reference: https://dom.spec.whatwg.org/#dom-childnode-remove
   */
  static JSValueRef remove(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef removeChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef insertBefore(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef replaceChild(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);

  JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSNode() = delete;
  explicit JSNode(JSContext *context);
  explicit JSNode(JSContext *context, const char *name);
  ~JSNode();

  JSFunctionHolder m_cloneNode{context, prototypeObject, this, "cloneNode", cloneNode};
  JSFunctionHolder m_removeChild{context, prototypeObject, this, "removeChild", removeChild};
  JSFunctionHolder m_appendChild{context, prototypeObject, this, "appendChild", appendChild};
  JSFunctionHolder m_remove{context, prototypeObject, this, "remove", remove};
  JSFunctionHolder m_insertBefore{context, prototypeObject, this, "insertBefore", insertBefore};
  JSFunctionHolder m_replaceChild{context, prototypeObject, this, "replaceChild", replaceChild};

private:
  friend NodeInstance;
  static void traverseCloneNode(JSContextRef ctx, NodeInstance* element, NodeInstance* parentElement);
  static JSValueRef copyNodeValue(JSContextRef ctx, NodeInstance* element);
};

class NodeInstance : public EventTargetInstance {
public:
  NodeInstance() = delete;
  NodeInstance(JSNode *node, NodeType nodeType);
  NodeInstance(JSNode *node, NodeType nodeType, int64_t targetId);
  ~NodeInstance() override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

  bool isConnected();
  DocumentInstance *ownerDocument();
  NodeInstance *firstChild();
  NodeInstance *lastChild();
  NodeInstance *previousSibling();
  NodeInstance *nextSibling();
  void internalAppendChild(NodeInstance *node);
  void internalRemove(JSValueRef *exception);
  NodeInstance *internalRemoveChild(NodeInstance *node, JSValueRef *exception);
  void internalInsertBefore(NodeInstance *node, NodeInstance *referenceNode, JSValueRef *exception);
  virtual std::string internalGetTextContent();
  virtual void internalSetTextContent(JSStringRef content, JSValueRef *exception);
  NodeInstance *internalReplaceChild(NodeInstance *newChild, NodeInstance *oldChild, JSValueRef *exception);

  NodeType nodeType;
  NodeInstance *parentNode{nullptr};
  std::vector<NodeInstance *> childNodes;

  NativeNode *nativeNode{nullptr};

  void refer();
  void unrefer();

  inline DocumentInstance *document() { return m_document; }

  int32_t _referenceCount{0};
  virtual void _notifyNodeRemoved(NodeInstance *node);
  virtual void _notifyNodeInsert(NodeInstance *node);

private:
  DocumentInstance *m_document{nullptr};
  void ensureDetached(NodeInstance *node);
  friend DocumentInstance;
  friend JSNode;
};

struct NativeNode {
  NativeNode() = delete;
  KRAKEN_EXPORT NativeNode(NativeEventTarget *nativeEventTarget) : nativeEventTarget(nativeEventTarget){};
  NativeEventTarget *nativeEventTarget;
};

class JSDocument : public JSNode {
public:
  static std::unordered_map<JSContext *, JSDocument *> instanceMap;
  static JSDocument *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  static JSValueRef createEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef createElement(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef createTextNode(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef createComment(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getElementById(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef getElementsByTagName(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                         size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

private:
protected:
  JSDocument() = delete;
  JSDocument(JSContext *context);
  ~JSDocument();


  JSFunctionHolder m_createEvent{context, prototypeObject, this, "createEvent", createEvent};
  JSFunctionHolder m_createElement{context, prototypeObject, this, "createElement", createElement};
  JSFunctionHolder m_createTextNode{context, prototypeObject, this, "createTextNode", createTextNode};
  JSFunctionHolder m_createComment{context, prototypeObject, this, "createComment", createComment};
  JSFunctionHolder m_getElementById{context, prototypeObject, this, "getElementById", getElementById};
  JSFunctionHolder m_getElementsByTagName{context, prototypeObject, this, "getElementsByTagName", getElementsByTagName};
};

class DocumentCookie {
public:
  KRAKEN_EXPORT DocumentCookie() = default;

  KRAKEN_EXPORT std::string getCookie();
  KRAKEN_EXPORT void setCookie(std::string &str);

private:
  std::unordered_map<std::string, std::string> cookiePairs;
};

struct NativeDocument {
  NativeDocument() = delete;
  KRAKEN_EXPORT explicit NativeDocument(NativeNode *nativeNode) : nativeNode(nativeNode){};

  NativeNode *nativeNode;
};

class DocumentInstance : public NodeInstance {
public:
  DEFINE_OBJECT_PROPERTY(Document, 4, nodeName, all, cookie, documentElement);
  DEFINE_PROTOTYPE_OBJECT_PROPERTY(Document, 6, createElement, createTextNode, createComment, getElementById,
                                   getElementsByTagName, createEvent);

  static DocumentInstance *instance(JSContext *context);

  DocumentInstance() = delete;
  KRAKEN_EXPORT explicit DocumentInstance(JSDocument *document);
  KRAKEN_EXPORT ~DocumentInstance();
  KRAKEN_EXPORT JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  KRAKEN_EXPORT bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  KRAKEN_EXPORT void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

  void removeElementById(JSValueRef id, ElementInstance *element);
  void addElementById(JSValueRef id, ElementInstance *element);

  NativeDocument *nativeDocument;
  std::unordered_map<std::string, std::vector<ElementInstance *>> elementMapById;

  ElementInstance *documentElement;

private:
  DocumentCookie m_cookie;
  friend NodeInstance;
};

class JSElementAttributes : public HostObject {
public:
  JSElementAttributes() = delete;
  JSElementAttributes(JSContext *context) : HostObject(context, "NamedNodeMap") {}
  ~JSElementAttributes() override;

  enum class AttributeProperty { kLength };

  static std::vector<JSStringRef> &getAttributePropertyNames();
  static std::unordered_map<std::string, AttributeProperty> &getAttributePropertyMap();

  KRAKEN_EXPORT JSValueRef getAttribute(std::string &name);
  KRAKEN_EXPORT void setAttribute(std::string &name, JSValueRef value);
  KRAKEN_EXPORT bool hasAttribute(std::string &name);
  KRAKEN_EXPORT void removeAttribute(std::string &name);

  KRAKEN_EXPORT std::map<std::string, JSValueRef>& getAttributesMap();
  KRAKEN_EXPORT void setAttributesMap(std::map<std::string, JSValueRef>& attributes);

  KRAKEN_EXPORT std::vector<JSValueRef>& getAttributesVector();
  KRAKEN_EXPORT void setAttributesVector(std::vector<JSValueRef>& attributes);

  KRAKEN_EXPORT JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  KRAKEN_EXPORT bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  KRAKEN_EXPORT void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  std::map<std::string, JSValueRef> m_attributes;
  std::vector<JSValueRef> v_attributes;
};

struct NativeBoundingClientRect {
  double x;
  double y;
  double width;
  double height;
  double top;
  double right;
  double bottom;
  double left;
};

class CSSStyleDeclaration : public HostClass {
public:
  static std::unordered_map<JSContext *, CSSStyleDeclaration *> instanceMap;
  static CSSStyleDeclaration *instance(JSContext *context);

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  static JSValueRef setProperty(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef removeProperty(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef getPropertyValue(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

protected:
  CSSStyleDeclaration() = delete;
  ~CSSStyleDeclaration();
  explicit CSSStyleDeclaration(JSContext *context);

  JSFunctionHolder m_setProperty{context, prototypeObject, this, "setProperty", setProperty};
  JSFunctionHolder m_getPropertyValue{context, prototypeObject, this, "getPropertyValue", getPropertyValue};
  JSFunctionHolder m_removeProperty{context, prototypeObject, this, "removeProperty", removeProperty};
};

class StyleDeclarationInstance : public HostClass::Instance {
public:
  DEFINE_PROTOTYPE_OBJECT_PROPERTY(CSSStyleDeclaration, 3, setProperty, removeProperty, getPropertyValue);

  StyleDeclarationInstance() = delete;
  StyleDeclarationInstance(CSSStyleDeclaration *cssStyleDeclaration, EventTargetInstance *ownerEventTarget);
  ~StyleDeclarationInstance();

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  bool internalSetProperty(std::string &name, JSValueRef value, JSValueRef *exception);
  void internalRemoveProperty(std::string &name, JSValueRef *exception);
  JSValueRef internalGetPropertyValue(std::string &name, JSValueRef *exception);

private:
  std::unordered_map<std::string, JSValueRef> properties;
  const EventTargetInstance *ownerEventTarget;
};

using ElementCreator = ElementInstance *(*)(JSContext *context);

class KRAKEN_EXPORT JSElement : public JSNode {
public:
  DEFINE_OBJECT_PROPERTY(Element, 17, style, attributes, nodeName, tagName, offsetLeft, offsetTop, offsetWidth,
                         offsetHeight, clientWidth, clientHeight, clientTop, clientLeft, scrollTop, scrollLeft,
                         scrollHeight, scrollWidth, children);

  DEFINE_PROTOTYPE_OBJECT_PROPERTY(Element, 10, getBoundingClientRect, getAttribute, setAttribute, hasAttribute,
                                   removeAttribute, toBlob, click, scroll, scrollBy, scrollTo);

  static std::unordered_map<JSContext *, JSElement *> instanceMap;
  static std::unordered_map<std::string, ElementCreator> elementCreatorMap;
  OBJECT_INSTANCE(JSElement)

  static ElementInstance *buildElementInstance(JSContext *context, std::string &tagName);

  JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception) override;

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  static void defineElement(std::string tagName, ElementCreator creator);

protected:
  JSElement() = delete;
  explicit JSElement(JSContext *context);
  ~JSElement();

private:
  friend ElementInstance;

  static JSValueRef getBoundingClientRect(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                          size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef hasAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef setAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef getAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                 const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef removeAttribute(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef toBlob(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef click(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                          const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef scroll(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                           const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef scrollBy(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                             const JSValueRef arguments[], JSValueRef *exception);
  JSFunctionHolder m_getBoundingClientRect{context, prototypeObject, this, "getBoundingClientRect",
                                           getBoundingClientRect};
  JSFunctionHolder m_setAttribute{context, prototypeObject, this, "setAttribute", setAttribute};
  JSFunctionHolder m_getAttribute{context, prototypeObject, this, "getAttribute", getAttribute};
  JSFunctionHolder m_hasAttribute{context, prototypeObject, this, "hasAttribute", hasAttribute};
  JSFunctionHolder m_removeAttribute{context, prototypeObject, this, "removeAttribute", removeAttribute};
  JSFunctionHolder m_toBlob{context, prototypeObject, this, "toBlob", toBlob};
  JSFunctionHolder m_click{context, prototypeObject, this, "click", click};
  JSFunctionHolder m_scroll{context, prototypeObject, this, "scroll", scroll};
  JSFunctionHolder m_scrollTo{context, prototypeObject, this, "scrollTo", scroll};
  JSFunctionHolder m_scrollBy{context, prototypeObject, this, "scrollBy", scrollBy};
};

class KRAKEN_EXPORT ElementInstance : public NodeInstance {
public:
  ElementInstance() = delete;
  explicit ElementInstance(JSElement *element, const char *tagName, bool shouldAddUICommand);
  explicit ElementInstance(JSElement *element, JSStringRef tagName, double targetId);
  ~ElementInstance();

  JSValueRef getStringValueProperty(std::string &name);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  std::string internalGetTextContent() override;
  void internalSetTextContent(JSStringRef content, JSValueRef *exception) override;
  JSHostObjectHolder<JSElementAttributes>& getAttributes();
  JSHostClassHolder& getStyle();
  void setStyle(JSHostClassHolder& style);
  void setAttributes(JSHostObjectHolder<JSElementAttributes>& attributes);

  NativeElement *nativeElement{nullptr};

  std::string tagName();

  std::string getRegisteredTagName();

private:
  friend JSElement;
  JSStringHolder m_tagName{context, ""};

  KRAKEN_EXPORT void _notifyNodeRemoved(NodeInstance *node) override;
  void _notifyChildRemoved();
  KRAKEN_EXPORT void _notifyNodeInsert(NodeInstance *insertNode) override;
  void _notifyChildInsert();
  void _didModifyAttribute(std::string &name, JSValueRef oldId, JSValueRef newId);
  void _beforeUpdateId(JSValueRef oldId, JSValueRef newId);
  JSHostObjectHolder<JSElementAttributes> m_attributes{context, object, "attributes", new JSElementAttributes(context)};
  JSHostClassHolder m_style{context, object, "style",
                            new StyleDeclarationInstance(CSSStyleDeclaration::instance(context), this)};
};

enum class ViewModuleProperty {
  offsetTop,
  offsetLeft,
  offsetWidth,
  offsetHeight,
  clientWidth,
  clientHeight,
  clientTop,
  clientLeft,
  scrollTop,
  scrollLeft,
  scrollHeight,
  scrollWidth
};
using GetViewModuleProperty = double (*)(NativeElement *nativeElement, int64_t property);
using SetViewModuleProperty = void (*)(NativeElement *nativeElement, int64_t property, double value);
using GetBoundingClientRect = NativeBoundingClientRect *(*)(NativeElement *nativeElement);
using GetStringValueProperty = NativeString *(*)(NativeElement *nativeElement, NativeString *property);
using Click = void (*)(NativeElement *nativeElement);
using Scroll = void (*)(NativeElement *nativeElement, int32_t x, int32_t y);
using ScrollBy = void (*)(NativeElement *nativeElement, int32_t x, int32_t y);

class BoundingClientRect : public HostObject {
public:
  enum BoundingClientRectProperty { kX, kY, kWidth, kHeight, kLeft, kTop, kRight, kBottom };

  static std::array<JSStringRef, 8> &getBoundingClientRectPropertyNames();
  static std::unordered_map<std::string, BoundingClientRectProperty> &getPropertyMap();

  BoundingClientRect() = delete;
  ~BoundingClientRect() override;
  BoundingClientRect(JSContext *context, NativeBoundingClientRect *boundingClientRect);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;

private:
  NativeBoundingClientRect *nativeBoundingClientRect;
};

// An struct represent Element object from dart side.
struct NativeElement {
  NativeElement() = delete;
  explicit NativeElement(NativeNode *nativeNode) : nativeNode(nativeNode){};

  const NativeNode *nativeNode;

  GetViewModuleProperty getViewModuleProperty{nullptr};
  SetViewModuleProperty setViewModuleProperty{nullptr};
  GetBoundingClientRect getBoundingClientRect{nullptr};
  GetStringValueProperty getStringValueProperty{nullptr};
  Click click{nullptr};
  Scroll scroll{nullptr};
  ScrollBy scrollBy{nullptr};
};

struct NativeGestureEvent {
  NativeGestureEvent() = delete;
  explicit NativeGestureEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;
  NativeString *state;
  NativeString *direction;
  double_t deltaX;
  double_t deltaY;
  double_t velocityX;
  double_t velocityY;
  double_t scale;
  double_t rotation;
};

class JSGestureEvent : public JSEvent {
public:
  DEFINE_OBJECT_PROPERTY(GestureEvent, 8, state, direction, deltaX, deltaY, velocityX, velocityY, scale, rotation);

  DEFINE_PROTOTYPE_OBJECT_PROPERTY(GestureEvent, 1, initGestureEvent);

  static std::unordered_map<JSContext *, JSGestureEvent *> instanceMap;
  OBJECT_INSTANCE(JSGestureEvent)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSGestureEvent() = delete;
  explicit JSGestureEvent(JSContext *context);
  ~JSGestureEvent() override;

private:
  friend GestureEventInstance;

  JSFunctionHolder m_initGestureEvent{context, prototypeObject, this, "initGestureEvent", initGestureEvent};

  static JSValueRef initGestureEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
};

class GestureEventInstance : public EventInstance {
public:
  GestureEventInstance() = delete;
  explicit GestureEventInstance(JSGestureEvent *jsGestureEvent, std::string GestureEventType, JSValueRef eventInit,
                                JSValueRef *exception);
  explicit GestureEventInstance(JSGestureEvent *jsGestureEvent, NativeGestureEvent *nativeGestureEvent);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~GestureEventInstance() override;

private:
  friend JSGestureEvent;
  JSValueHolder m_state{context, nullptr};
  JSValueHolder m_direction{context, nullptr};
  JSValueHolder m_deltaX{context, nullptr};
  JSValueHolder m_deltaY{context, nullptr};
  JSValueHolder m_velocityX{context, nullptr};
  JSValueHolder m_velocityY{context, nullptr};
  JSValueHolder m_scale{context, nullptr};
  JSValueHolder m_rotation{context, nullptr};
  NativeGestureEvent *nativeGestureEvent;
};

struct NativeMouseEvent {
  NativeMouseEvent() = delete;
  explicit NativeMouseEvent(NativeEvent *nativeEvent) : nativeEvent(nativeEvent){};

  NativeEvent *nativeEvent;

  double_t clientX;

  double_t clientY;

  double_t offsetX;

  double_t offsetY;
};

class JSMouseEvent : public JSEvent {
public:
  DEFINE_OBJECT_PROPERTY(MouseEvent, 4, clientX, clientY, offsetX, offsetY);

  DEFINE_PROTOTYPE_OBJECT_PROPERTY(MouseEvent, 1, initMouseEvent);

  static std::unordered_map<JSContext *, JSMouseEvent *> instanceMap;
  OBJECT_INSTANCE(JSMouseEvent)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;

protected:
  JSMouseEvent() = delete;
  explicit JSMouseEvent(JSContext *context);
  ~JSMouseEvent() override;

private:
  friend MouseEventInstance;

  JSFunctionHolder m_initMouseEvent{context, prototypeObject, this, "initMouseEvent", initMouseEvent};

  static JSValueRef initMouseEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);
};

class MouseEventInstance : public EventInstance {
public:
  MouseEventInstance() = delete;
  explicit MouseEventInstance(JSMouseEvent *jsMouseEvent, std::string MouseEventType, JSValueRef eventInit,
                                JSValueRef *exception);
  explicit MouseEventInstance(JSMouseEvent *jsMouseEvent, NativeMouseEvent *nativeMouseEvent);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  bool setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~MouseEventInstance() override;

private:
  friend JSMouseEvent;
  JSValueHolder m_clientX{context, nullptr};
  JSValueHolder m_clientY{context, nullptr};
  JSValueHolder m_offsetX{context, nullptr};
  JSValueHolder m_offsetY{context, nullptr};
  NativeMouseEvent *nativeMouseEvent;
};

} // namespace kraken::binding::jsc

KRAKEN_EXPORT
JSGlobalContextRef getGlobalContextRef(int32_t contextId);

#endif
