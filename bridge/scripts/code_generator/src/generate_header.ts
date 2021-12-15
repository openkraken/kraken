import {ClassObject, PropsDeclaration, PropsDeclarationKind} from "./declaration";
import {uniqBy} from "lodash";
import {Blob} from "./blob";
import {addIndent} from "./utils";

function generatePropsHeader(object: ClassObject, type: PropType) {
  let propsDefine = '';
  if (object.props.length > 0) {

    if (type == PropType.hostObject) {
      for (let i = 0; i < object.props.length; i ++) {
        let p = object.props[i];

        if (p.readonly) {
          propsDefine += `DEFINE_READONLY_PROPERTY(${p.name});\n`;
        } else {
          propsDefine += `DEFINE_PROPERTY(${p.name});\n`;
        }
      }
    } else {
      for (let i = 0; i < object.props.length; i ++) {
        let p = object.props[i];
        if (p.readonly) {
          propsDefine += `DEFINE_PROTOTYPE_READONLY_PROPERTY(${p.name});\n`;
        } else {
          propsDefine += `DEFINE_PROTOTYPE_PROPERTY(${p.name});\n`;
        }
      }
    }
  }
  return propsDefine;
}

enum PropType {
  hostObject,
  hostClass,
}

function generateMethodsHeader(object: ClassObject, type: PropType) {
  let methodsDefine: string[] = [];
  let methodsImpl: string[] = [];
  if (object.methods.length > 0) {
    let methods = uniqBy(object.methods, (o) => o.name);
    methodsDefine = methods.map(o => `static JSValue ${o.name}(JSContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);`);

    if (type == PropType.hostClass) {
      methodsImpl = methods.map(o => `DEFINE_PROTOTYPE_FUNCTION(${o.name}, ${o.args.length});`)
    } else {
      methodsImpl = methods.map(o => `DEFINE_FUNCTION(${o.name}, ${o.args.length});`)
    }
  }
  return {
    methodsImpl,
    methodsDefine
  }
}

function generateHostObjectHeader(object: ClassObject) {
  let propsDefine = generatePropsHeader(object, PropType.hostObject);
  let {methodsImpl, methodsDefine} = generateMethodsHeader(object, PropType.hostObject);

  return `\n
struct Native${object.name} {
  CallNativeMethods callNativeMethods{nullptr};
};

class ${object.name} : public ${object.type} {
public:
  ${object.name}() = delete;
  explicit ${object.name}(ExecutionContext *context, Native${object.name} *nativePtr);

  JSValue callNativeMethods(const char* method, int32_t argc,
                          NativeValue *argv);


  ${methodsDefine.join('\n  ')}

private:
  Native${object.name} *m_nativePtr{nullptr};
  ${propsDefine}

  ${methodsImpl.join('\n  ')}
};`;
}

function generateHostClassHeader(object: ClassObject) {
  let {methodsImpl, methodsDefine} = generateMethodsHeader(object, PropType.hostClass);
  let propsDefine = generatePropsHeader(object, PropType.hostClass);

  let nativeStructCode = '';

  if (object.type === 'Event') {
    let nativeStructPropsCode = object.props.map(p => {
      switch(p.kind) {
        case PropsDeclarationKind.object:
        case PropsDeclarationKind.string:
          return `NativeString *${p.name};`;
        case PropsDeclarationKind.double:
          return `double ${p.name};`;
        case PropsDeclarationKind.int64:
        case PropsDeclarationKind.boolean:
          return `int64_t ${p.name};`;
      }
      return null;
    }).filter(p => !!p);

    nativeStructCode = `struct Native${object.name} {
  NativeEvent nativeEvent;
${addIndent(nativeStructPropsCode.join('\n'), 2)}
};`;
  }

  let constructorHeader = `\n
void bind${object.name}(std::unique_ptr<ExecutionContext> &context);

class ${object.name}Instance;

${nativeStructCode}
class ${object.name} : public ${object.type} {
public:
  ${object.name}() = delete;
  explicit ${object.name}(ExecutionContext *context);
  JSValue instanceConstructor(JSContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;
  ${methodsDefine.join('\n  ')}
  OBJECT_INSTANCE(${object.name});
private:
  ${propsDefine}
  ${methodsImpl.join('\n  ')}
  friend ${object.name}Instance;
};`;

  let instanceConstructorHeader = ``;
  if (object.type === 'Event') {
    instanceConstructorHeader = `explicit ${object.name}Instance(${object.name} *${object.type.toLowerCase()}, NativeEvent *nativeEvent);`;
  } else {
    instanceConstructorHeader = `explicit ${object.name}Instance(${object.name} *${object.type.toLowerCase()});`;
  }

  let instanceHeaders = `class ${object.name}Instance : public ${object.type}Instance {
public:
  ${object.name}Instance() = delete;
  ${instanceConstructorHeader}
private:
  friend ${object.name};
};
`;

  return constructorHeader + '\n' + instanceHeaders;
}

function generateObjectHeader(object: ClassObject) {
  if (object.type === 'HostClass' || object.type === 'Element' || object.type === 'Event') {
    return generateHostClassHeader(object);
  } else if (object.type === 'HostObject') {
    return generateHostObjectHeader(object);
  }
  return null;
}

export function generateCppHeader(blob: Blob) {
  let headers = blob.objects.map(o => generateObjectHeader(o));

  return `/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_${blob.filename.toUpperCase()}_H
#define KRAKENBRIDGE_${blob.filename.toUpperCase()}_H

#include "bindings/qjs/dom/element.h"

namespace kraken::binding::qjs {
${headers.join('')}
}

#endif //KRAKENBRIDGE_${blob.filename.toUpperCase()}T_H
`;
}
