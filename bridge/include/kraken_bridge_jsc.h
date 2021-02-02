#include <JavaScriptCore/JavaScript.h>
#include <chrono>
#include <functional>

#define EXPORT __attribute__((__visibility__("default")))

#define KRAKEN_DISALLOW_COPY(TypeName) TypeName(const TypeName &) = delete

#define KRAKEN_DISALLOW_ASSIGN(TypeName) TypeName &operator=(const TypeName &) = delete

#define KRAKEN_DISALLOW_MOVE(TypeName)                                                                                 \
  TypeName(TypeName &&) = delete;                                                                                      \
  TypeName &operator=(TypeName &&) = delete

#define FML_DISALLOW_COPY_AND_ASSIGN(TypeName)                                                                         \
  TypeName(const TypeName &) = delete;                                                                                 \
  TypeName &operator=(const TypeName &) = delete

#define FML_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName)                                                                    \
  TypeName(const TypeName &) = delete;                                                                                 \
  TypeName(TypeName &&) = delete;                                                                                      \
  TypeName &operator=(const TypeName &) = delete;                                                                      \
  TypeName &operator=(TypeName &&) = delete

#define FML_DISALLOW_IMPLICIT_CONSTRUCTORS(TypeName)                                                                   \
  TypeName() = delete;                                                                                                 \
  FML_DISALLOW_COPY_ASSIGN_AND_MOVE(TypeName)

using JSExceptionHandler = std::function<void(int32_t contextId, const char *errmsg)>;

class NativeString;

namespace kraken::binding::jsc {

class JSContext;
class JSFunctionHolder;
class JSStringHolder;
class JSValueHolder;

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

} // namespace kraken::binding::jsc
