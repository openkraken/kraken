#include <JavaScriptCore/JavaScript.h>
#include <chrono>
#include <deque>
#include <functional>
#include <unordered_map>
#include <vector>

#include "kraken_bridge_jsc_config.h"

using JSExceptionHandler = std::function<void(int32_t contextId, const char *errmsg)>;

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

class EXPORT JSContext {
public:
  static std::vector<JSStaticFunction> globalFunctions;
  static std::vector<JSStaticValue> globalValue;

  JSContext() = delete;
  JSContext(int32_t contextId, const JSExceptionHandler &handler, void *owner);
  ~JSContext();

  bool evaluateJavaScript(const uint16_t *code, size_t codeLength, const char *sourceURL, int startLine);
  bool evaluateJavaScript(const char16_t *code, size_t length, const char *sourceURL, int startLine);

  bool isValid();

  JSObjectRef global();
  JSGlobalContextRef context();

  int32_t getContextId();

  void *getOwner();

  bool handleException(JSValueRef exc);

  void reportError(const char *errmsg);

  std::chrono::time_point<std::chrono::system_clock> timeOrigin;

  int32_t uniqueId;

private:
  int32_t contextId;
  JSExceptionHandler _handler;
  void *owner;
  std::atomic<bool> ctxInvalid_{false};
  JSGlobalContextRef ctx_;
};

class EXPORT JSFunctionHolder {
public:
  JSFunctionHolder() = delete;
  explicit JSFunctionHolder(JSContext *context, void *data, std::string name, JSObjectCallAsFunctionCallback callback);
  explicit JSFunctionHolder(JSContext *context, std::string name, JSObjectCallAsFunctionCallback callback);
  ~JSFunctionHolder();

  JSObjectRef function();

private:
  JSObjectRef m_function{nullptr};
  JSContext *context{nullptr};
  void *m_data{nullptr};
  std::string m_name;
  JSObjectCallAsFunctionCallback m_callback{nullptr};
  FML_DISALLOW_COPY_ASSIGN_AND_MOVE(JSFunctionHolder);
};

class EXPORT JSStringHolder {
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
  FML_DISALLOW_COPY_ASSIGN_AND_MOVE(JSStringHolder);
};

class EXPORT JSValueHolder {
public:
  JSValueHolder() = delete;
  explicit JSValueHolder(JSContext *context, JSValueRef value);
  ~JSValueHolder();
  JSValueRef value();

  void setValue(JSValueRef value);

private:
  JSContext *m_context;
  JSValueRef m_value{nullptr};
  FML_DISALLOW_COPY_ASSIGN_AND_MOVE(JSValueHolder);
};

void EXPORT buildUICommandArgs(JSStringRef key, NativeString &args_01);
void EXPORT buildUICommandArgs(std::string &key, NativeString &args_01);
void EXPORT buildUICommandArgs(std::string &key, JSStringRef value, NativeString &args_01, NativeString &args_02);
void EXPORT buildUICommandArgs(std::string &key, std::string &value, NativeString &args_01, NativeString &args_02);

void EXPORT throwJSError(JSContextRef ctx, const char *msg, JSValueRef *exception);

EXPORT NativeString *stringToNativeString(std::string &string);
EXPORT NativeString *stringRefToNativeString(JSStringRef string);

class EXPORT HostObject {
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
  virtual JSValueRef getProperty(std::string &name, JSValueRef *exception);

  // When JS wants to set a property with a given name on the HostObject,
  // it will call this method. If it throws an exception, the call will
  // throw a JS \c Error object. By default this throws a type error exception
  // mimicking the behavior of a frozen object in strict mode.
  virtual void setProperty(std::string &name, JSValueRef value, JSValueRef *exception);

  virtual void getPropertyNames(JSPropertyNameAccumulatorRef accumulator);

private:
  JSClassRef jsClass;
  std::unordered_map<std::string, JSValueRef> m_propertyMap;
};

template <typename T> class EXPORT JSHostObjectHolder {
public:
  JSHostObjectHolder() = delete;
  explicit JSHostObjectHolder(JSContext *context, T *hostObject) : m_object(hostObject), m_context(context) {
    JSValueProtect(m_object->ctx, m_object->jsObject);
  }
  ~JSHostObjectHolder() {
    if (m_context->isValid()) {
      JSValueUnprotect(m_object->ctx, m_object->jsObject);
    }
  }
  T *operator*() {
    return m_object;
  }

private:
  T *m_object;
  JSContext *m_context{nullptr};
};

class EXPORT HostClass {
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

  virtual JSValueRef getProperty(std::string &name, JSValueRef *exception);
  virtual JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception);

  // Triggered when this HostClass had been finalized by GC.
  virtual ~HostClass();

  virtual JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                          const JSValueRef *arguments, JSValueRef *exception);

  // The instance class represent every javascript instance objects created by new expression.
  class Instance {
  public:
    Instance() = delete;
    explicit Instance(HostClass *hostClass);
    virtual ~Instance();
    virtual JSValueRef getProperty(std::string &name, JSValueRef *exception);
    virtual void setProperty(std::string &name, JSValueRef value, JSValueRef *exception);
    virtual void getPropertyNames(JSPropertyNameAccumulatorRef accumulator);

    template <typename T> T *prototype() {
      return reinterpret_cast<T *>(_hostClass);
    }

    JSObjectRef object{nullptr};
    HostClass *_hostClass{nullptr};
    JSContext *context{nullptr};
    JSContextRef ctx{nullptr};
    int32_t contextId;

  private:
    std::unordered_map<std::string, JSValueRef> m_propertyMap;
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
  void initPrototype() const;

  // The class template of javascript constructor function.
  JSClassRef jsClass{nullptr};
  HostClass *_parentHostClass{nullptr};
};

class JSEvent : public HostClass {
public:
  DEFINE_OBJECT_PROPERTY(Event, 13, type, bubbles, cancelable, timestamp, defaultPrevented, target, srcElement,
                         currentTarget, returnValue, stopPropagation, cancelBubble, stopImmediatePropagation,
                         preventDefault)

  static std::unordered_map<JSContext *, JSEvent *> instanceMap;
  OBJECT_INSTANCE(JSEvent)
  // Create an Event Object from an nativeEvent address which allocated by dart side.
  static JSValueRef initWithNativeEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef stopPropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                    size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef stopImmediatePropagation(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                             size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef preventDefault(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  static EventInstance *buildEventInstance(std::string &eventType, JSContext *context, void *nativeEvent,
                                           bool isCustomEvent);

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
  JSFunctionHolder m_initWithNativeEvent{context, this, "initWithNativeEvent", initWithNativeEvent};
  JSFunctionHolder m_stopImmediatePropagation{context, this, "stopImmediatePropagation", stopImmediatePropagation};
  JSFunctionHolder m_stopPropagation{context, this, "stopPropagation", stopPropagation};
  JSFunctionHolder m_preventDefault{context, this, "preventDefault", preventDefault};
};

class EventInstance : public HostClass::Instance {
public:
  EventInstance() = delete;

  explicit EventInstance(JSEvent *jsEvent, NativeEvent *nativeEvent);
  explicit EventInstance(JSEvent *jsEvent, std::string eventType, JSValueRef eventInit, JSValueRef *exception);
  JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
  void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
  void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
  ~EventInstance() override;
  NativeEvent *nativeEvent;
  bool _dispatchFlag{false};
  bool _canceledFlag{false};
  bool _initializedFlag{true};
  bool _stopPropagationFlag{false};
  bool _stopImmediatePropagationFlag{false};
  bool _inPassiveListenerFlag{false};

private:
  friend JSEvent;
};

struct NativeEvent {
  NativeEvent() = delete;
  explicit NativeEvent(NativeString *eventType) : type(eventType){};
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
  DEFINE_OBJECT_PROPERTY(EventTarget, 5, addEventListener, removeEventListener, dispatchEvent, __clearListeners__,
                         eventTargetId)

  JSObjectRef instanceConstructor(JSContextRef ctx, JSObjectRef constructor, size_t argumentCount,
                                  const JSValueRef *arguments, JSValueRef *exception) override;

  JSValueRef prototypeGetProperty(std::string &name, JSValueRef *exception) override;

  static JSValueRef addEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                     size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef removeEventListener(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject,
                                        size_t argumentCount, const JSValueRef arguments[], JSValueRef *exception);

  static JSValueRef dispatchEvent(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                  const JSValueRef arguments[], JSValueRef *exception);
  static JSValueRef clearListeners(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount,
                                   const JSValueRef arguments[], JSValueRef *exception);

  class EventTargetInstance : public Instance {
  public:
    EventTargetInstance() = delete;
    explicit EventTargetInstance(JSEventTarget *eventTarget);
    explicit EventTargetInstance(JSEventTarget *eventTarget, int64_t targetId);
    JSValueRef getProperty(std::string &name, JSValueRef *exception) override;
    void setProperty(std::string &name, JSValueRef value, JSValueRef *exception) override;
    void getPropertyNames(JSPropertyNameAccumulatorRef accumulator) override;
    JSValueRef getPropertyHandler(std::string &name, JSValueRef *exception);
    void setPropertyHandler(std::string &name, JSValueRef value, JSValueRef *exception);
    bool dispatchEvent(EventInstance *event);

    ~EventTargetInstance() override;
    int32_t eventTargetId;
    NativeEventTarget *nativeEventTarget{nullptr};

  private:
    friend JSEventTarget;
    // TODO: use std::u16string for better performance.
    std::unordered_map<std::string, std::deque<JSObjectRef>> _eventHandlers;
    bool internalDispatchEvent(EventInstance *eventInstance);
  };

protected:
  JSEventTarget() = delete;
  friend EventTargetInstance;
  explicit JSEventTarget(JSContext *context, const char *name);
  explicit JSEventTarget(JSContext *context, const JSStaticFunction *staticFunction, const JSStaticValue *staticValue);
  ~JSEventTarget();

private:
  JSFunctionHolder m_removeEventListener{context, this, "removeEventListener", removeEventListener};
  JSFunctionHolder m_dispatchEvent{context, this, "dispatchEvent", dispatchEvent};
  JSFunctionHolder m_clearListeners{context, this, "clearListeners", clearListeners};
  JSFunctionHolder m_addEventListener{context, this, "addEventListener", addEventListener};
  std::vector<std::string> m_jsOnlyEvents;
};

using NativeDispatchEvent = void (*)(NativeEventTarget *nativeEventTarget, NativeString *eventType, void *nativeEvent,
                                     int32_t isCustomEvent);

struct NativeEventTarget {
  NativeEventTarget() = delete;
  NativeEventTarget(JSEventTarget::EventTargetInstance *_instance)
    : instance(_instance), dispatchEvent(NativeEventTarget::dispatchEventImpl){};

  static void dispatchEventImpl(NativeEventTarget *nativeEventTarget, NativeString *eventType, void *nativeEvent,
                                int32_t isCustomEvent);

  JSEventTarget::EventTargetInstance *instance;
  NativeDispatchEvent dispatchEvent;
};

} // namespace kraken::binding::jsc
