#include "core/<%= blob.implement %>.h"

namespace kraken {

class ExecutingContext;

class QJS<%= className %> : public QJSInterfaceBridge<QJS<%= className %>, <%= className%>> {
 public:
  static void Install(ExecutingContext* context);
  static WrapperTypeInfo* GetWrapperTypeInfo() {
    return const_cast<WrapperTypeInfo*>(&wrapper_type_info_);
  }
  static JSValue ConstructorCallback(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv, int flags);
  static const WrapperTypeInfo wrapper_type_info_;
 private:
  static void InstallGlobalFunctions(ExecutingContext* context);
  static void InstallPrototypeMethods(ExecutingContext* context);
  static void InstallPrototypeProperties(ExecutingContext* context);
  static void InstallConstructor(ExecutingContext* context);
};


}
