import {ClassObject, FunctionArguments, FunctionDeclaration} from "./declaration";
import {Blob} from './blob';
import { uniqBy } from 'lodash';

function generateCppSource(blob: Blob) {
  let sources = blob.objects.map(o => generateObjectSource(o));
  return `/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "canvas_element.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {
  ${sources.join('')}
}`;
}

function generateHostObjectSource(object: ClassObject) {
  let propSource: string[] = generatePropsSource(object);
  let methodsSource: string[] = generateMethodsSource(object);
return `${object.name}::${object.name}(JSContext *context,
                                                   Native${object.name} *nativePtr)
  : HostObject(context, "${object.name}"), m_nativePtr(nativePtr) {
}

${propSource.join('\n')}
${methodsSource.join('\n')}
`;
}

function generatePropsSource(object: ClassObject) {
  let propSource: string[] = [];
  if (object.props.length > 0) {
    object.props.forEach(p => {
      let getter = `PROP_GETTER(${object.name}Instance, ${p.name})(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<${object.name}Instance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods('${p.name}', 0, nullptr);
}`;
      let setter = `PROP_SETTER(${object.name}Instance, ${p.name})(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}`;
      propSource.push(getter + '\n' + setter);
    });
  }
  return propSource;
}

function generateArgumentsTypeCheck(index: number, argv: FunctionArguments, m: FunctionDeclaration) {
  if (argv.type == 'string') {
    return `if (!JS_IsString(argv[${index}])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ${m.name}: ${index + 1}st arguments is not String.");
  }`;
  } else if (argv.type === 'number') {
    return `if (!JS_IsNumber(argv[${index}])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ${m.name}: ${index + 1}st arguments is not Number.");
  }`
  } else if (argv.type === 'boolean') {
    return `if (!JS_IsBool(argv[${index}])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ${m.name}: ${index + 1}st arguments is not Boolean.");
  }`
  }

  return '';
}

function generateMethodArgumentsCheck(m: FunctionDeclaration, object: ClassObject) {
  if (m.args.length == 0) return '';

  let requiredArgsCount = 0;
  m.args.forEach(m => {
    if (m.required) requiredArgsCount++;
  });

  let argsCheck: string[] = [];
  for (let i = 0; i < requiredArgsCount; i ++) {
    argsCheck.push(generateArgumentsTypeCheck(i, m.args[i], m));
  }

  return `  if (argc < ${requiredArgsCount}) {
    return JS_ThrowTypeError(ctx, "Failed to execute '${m.name}' on '${object.name}': ${requiredArgsCount} argument required, but %d present.", argc);
  }
  ${argsCheck.join('\n  ')}
`;
}

function generateMethodsSource(object: ClassObject) {
  let methodsSource: string[] = [];
  if (object.methods.length > 0) {
    object.methods.forEach(m => {
      let callArguments = [];
      for (let i = 0; i < m.args.length; i ++) {
        callArguments.push(` jsValueToNativeValue(ctx, argv[${i}])`);
      }

      let template = `JSValue ${object.name}::${m.name}(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
${generateMethodArgumentsCheck(m, object)}
  getDartMethod()->flushUICommand();
  NativeValue arguments[] = {
  ${callArguments.join(',\n  ')}
  }

  auto *element = static_cast<${object.name}Instance *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("${m.name}", ${m.args.length}, arguments);
}`;
      methodsSource.push(template);
    });
  }

  return methodsSource;
}

function generateHostClassSource(object: ClassObject) {
  let propSource: string[] = generatePropsSource(object);
  let methodsSource: string[] = generateMethodsSource(object);


  return `
${object.name}::${object.name}(JSContext *context) : Element(context) {}

JSValue ${object.name}::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}

${propSource.join('\n')}

${methodsSource.join('\n')}
`;
}

function generateObjectSource(object: ClassObject) {
  if (object.type === 'HostClass') {
    return generateHostClassSource(object);
  } else if (object.type === 'HostObject') {
    return generateHostObjectSource(object);
  }
  return null;
}

function generatePropsHeader(object: ClassObject) {
  let propsDefine = '';
  if (object.props.length > 0) {
    propsDefine = `DEFINE_HOST_OBJECT_PROPERTY(${object.props.length}, ${object.props.map(o => o.name).join(', ')})`;
  }
  return propsDefine;
}

function generateMethodsHeader(methodsDefine: string[], methodsImpl: string[], object: ClassObject) {
  if (object.methods.length > 0) {
    object.methods = uniqBy(object.methods, (o) => o.name);
    methodsDefine = object.methods.map(o => `static JSValue ${o.name}(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);`);
    methodsImpl = object.methods.map(o => `ObjectFunction m_${o.name}{m_context, m_prototypeObject, "${o.name}", ${o.name}, ${o.args.length}};`)
  }
}

function generateHostObjectHeader(object: ClassObject) {
  let propsDefine = generatePropsHeader(object);
  let methodsDefine: string[] = [];
  let methodsImpl: string[] = [];
  generateMethodsHeader(methodsDefine, methodsImpl, object);

  return `\n
struct Native${object.name} {
  CallNativeMethods callNativeMethods{nullptr};
}

class ${object.name} : public ${object.type} {
public:
  ${object.name}() = delete;
  explicit ${object.name}(JSContext *context, Native${object.name} *nativePtr);

  ${methodsDefine.join('\n  ')}

private:
  Native${object.name} *m_nativePtr{nullptr};
  ${propsDefine}

  ${methodsImpl.join('\n  ')}
}`;
}

function generateHostClassHeader(object: ClassObject) {
  let methodsDefine: string[] = [];
  let methodsImpl: string[] = [];
  if (object.methods.length > 0) {
    object.methods = uniqBy(object.methods, (o) => o.name);
    methodsDefine = object.methods.map(o => `static JSValue ${o.name}(QjsContext *ctx, JSValueConst this_val, int argc, JSValueConst *argv);`);
    methodsImpl = object.methods.map(o => `ObjectFunction m_${o.name}{m_context, m_prototypeObject, "${o.name}", ${o.name}, ${o.args.length}};`)
  }
  let propsDefine = '';
  if (object.props.length > 0) {
    propsDefine = `DEFINE_HOST_OBJECT_PROPERTY(${object.props.length}, ${object.props.map(o => o.name).join(', ')})`;
  }

  let constructorHeader = `\n
class ${object.name} : public Element {
public:
  ${object.name}() = delete;
  explicit ${object.name}(JSContext *context);
  JSValue constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) override;

  ${methodsDefine.join('\n  ')}

private:
  ${methodsImpl.join('\n  ')}
}`;
  let instanceHeaders = `\n
class ${object.name}Instance : public ElementInstance {
public:
  ${object.name}Instance() = delete;
  explicit ${object.name}Instance(${object.name} *element);
private:
  ${propsDefine}
}
`;

  return constructorHeader + '\n' + instanceHeaders;
}

function generateObjectHeader(object: ClassObject) {
  if (object.type === 'HostClass') {
    return generateHostClassHeader(object);
  } else if (object.type === 'HostObject') {
    return generateHostObjectHeader(object);
  }
  return null;
}

function generateCppHeader(blob: Blob) {
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

export function generatorSource(blob: Blob) {
  generateCppHeader(blob);
  console.log(generateCppSource(blob));
}
