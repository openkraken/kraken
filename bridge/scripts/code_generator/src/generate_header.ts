import {ClassObject, FunctionObject, PropsDeclaration} from "./declaration";
import {uniqBy, snakeCase} from "lodash";
import {Blob} from "./blob";
import {addIndent, getClassName} from "./utils";

function generateInterfaceAdditionalHeader(blob: Blob, object: any): [string, string, string] {
  if (!(object instanceof ClassObject)) {
    return ['', '', ''];
  }

  let wrapperTypeInfo = `static WrapperTypeInfo* GetWrapperTypeInfo() {
    return const_cast<WrapperTypeInfo*>(&wrapper_type_info_);
  }`;

  let wrapperTypeDefine = `static JSValue ConstructorCallback(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv, int flags);
  constexpr static const WrapperTypeInfo wrapper_type_info_ = {JS_CLASS_${getClassName(blob).toUpperCase()}, "${getClassName(blob)}", ${object.parent != null ? `${object.parent}::GetStaticWrapperTypeInfo()` : 'nullptr'}, ConstructorCallback};
`;

  let installFunctions = `static void InstallPrototypeMethods(ExecutingContext* context);
  static void InstallPrototypeProperties(ExecutingContext* context);
  static void InstallConstructor(ExecutingContext* context);`;

  return [
    wrapperTypeInfo,
    wrapperTypeDefine,
    installFunctions
  ];
}

export function generateCppHeader(blob: Blob) {
  let classObject = blob.objects.find(object => object instanceof ClassObject);
  let interfaceDefines = generateInterfaceAdditionalHeader(blob, classObject);
  let haveInterfaceBase = !!classObject;
  return `/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_${blob.filename.toUpperCase()}_H
#define KRAKENBRIDGE_${blob.filename.toUpperCase()}_H

#include <quickjs/quickjs.h>
#include "bindings/qjs/wrapper_type_info.h"
#include "bindings/qjs/qjs_interface_bridge.h"
#include "core/${blob.implement}.h"

namespace kraken {

class ExecutingContext;

class QJS${getClassName(blob)} ${haveInterfaceBase ? `: public QJSInterfaceBridge<QJS${getClassName(blob)}, ${getClassName(blob)}>` : 'final'} {
 public:
  static void Install(ExecutingContext* context);

  ${interfaceDefines[0]}
  ${interfaceDefines[1]}
 private:
  static void InstallGlobalFunctions(ExecutingContext* context);
  ${interfaceDefines[2]}
};

}

#endif //KRAKENBRIDGE_${blob.filename.toUpperCase()}T_H
`;
}
