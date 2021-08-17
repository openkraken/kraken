import {Blob} from "./blob";
import {ClassObject, FunctionArguments, FunctionDeclaration} from "./declaration";
import { findLastIndex, findIndex, remove } from 'lodash';

function generateHostObjectSource(object: ClassObject) {
  let propSource: string[] = generatePropsSource(object, PropType.hostObject);
  let methodsSource: string[] = generateMethodsSource(object, PropType.hostObject);
  return `${object.name}::${object.name}(JSContext *context,
                                                   Native${object.name} *nativePtr)
  : HostObject(context, "${object.name}"), m_nativePtr(nativePtr) {
}
JSValue ${object.name}::callNativeMethods(const char *method, int32_t argc,
                                               NativeValue *argv) {
  if (m_nativePtr->callNativeMethods == nullptr) {
    return JS_ThrowTypeError(m_ctx, "Failed to call native dart methods: callNativeMethods not initialized.");
  }

  std::u16string methodString;
  fromUTF8(method, methodString);

  NativeString m{
    reinterpret_cast<const uint16_t *>(methodString.c_str()),
    static_cast<int32_t>(methodString.size())
  };

  NativeValue nativeValue{};
  m_nativePtr->callNativeMethods(m_nativePtr, &nativeValue, &m, argc, argv);
  JSValue returnValue = nativeValueToJSValue(m_context, nativeValue);
  return returnValue;
}
${propSource.join('\n')}
${methodsSource.join('\n')}
`;
}

enum PropType {
  hostObject,
  hostClass
}

function generatePropsSource(object: ClassObject, type: PropType) {
  let propSource: string[] = [];
  if (object.props.length > 0) {
    object.props.forEach(p => {
      let getter = `PROP_GETTER(${object.name}${type == PropType.hostClass ? 'Instance' : ''}, ${p.name})(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  getDartMethod()->flushUICommand();
  auto *element = static_cast<${object.name}${type == PropType.hostClass ? 'Instance' : ''} *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("get${p.name[0].toUpperCase() + p.name.substring(1)}", 0, nullptr);
}`;
      let setter = `PROP_SETTER(${object.name}${type == PropType.hostClass ? 'Instance' : ''}, ${p.name})(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *element = static_cast<${object.name}${type == PropType.hostClass ? 'Instance' : ''} *>(JS_GetOpaque(this_val, Element::classId()));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return element->callNativeMethods("set${p.name[0].toUpperCase() + p.name.substring(1)}", 1, arguments);
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

function addIndent(str: String, space: number) {
  let lines = str.split('\n');
  lines = lines.map(l => {
    for (let i = 0; i < space; i ++) {
      l = ' ' + l;
    }
    return l;
  });
  return lines.join('\n');
}

function generateMethodsSource(object: ClassObject, type: PropType) {
  let methodsSource: string[] = [];
  if (object.methods.length > 0) {
    let methods = object.methods.slice();
    let polymorphismMap = {};
    methods.forEach((m) => {
      let polymorphism = object.methods.filter(me => me.name === m.name).length > 1;

      if (polymorphismMap[m.name]) return;

      polymorphismMap[m.name] = true;

      function createMethodBody(m: FunctionDeclaration) {
        let callArgumentsCode = '';
        if (m.args.length > 0) {
          let callArguments = [];
          for (let i = 0; i < m.args.length; i ++) {
            callArguments.push(` jsValueToNativeValue(ctx, argv[${i}])`);
          }
          callArgumentsCode = `NativeValue arguments[] = {
  ${callArguments.join(',\n  ')}
  };`;
        }

        return `${generateMethodArgumentsCheck(m, object)}
  getDartMethod()->flushUICommand();
${callArgumentsCode}
  auto *element = static_cast<${object.name}${type == PropType.hostObject ? '' : 'Instance'} *>(JS_GetOpaque(this_val, Element::classId()));
  return element->callNativeMethods("${m.name}", ${m.args.length}, ${m.args.length > 0 ? 'arguments' : 'nullptr'});`;
      }

      if (polymorphism) {
        let allConditions = object.methods.filter(me => me.name === m.name);
        let caseCode = [];
        for (let i = 0; i < allConditions.length; i ++) {
          caseCode.push(`case ${allConditions[i].args.length}: {
${addIndent(createMethodBody(allConditions[i]), 2)}
  }\n  `)
        }

        let polymorphismTemplate = `JSValue ${object.name}::${m.name}(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  switch(argc) {
  ${addIndent(caseCode.join(''), 2)}
  default:
    return JS_NULL;
  }
}`;
        methodsSource.push(polymorphismTemplate);
      } else {
        let body = createMethodBody(m);

        methodsSource.push(`JSValue ${object.name}::${m.name}(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
${body}
}`);
      }



    });
  }

  return methodsSource;
}

function generateHostClassSource(object: ClassObject) {
  let propSource: string[] = generatePropsSource(object, PropType.hostClass);
  let methodsSource: string[] = generateMethodsSource(object, PropType.hostClass);

  return `
${object.name}::${object.name}(JSContext *context) : Element(context) {}

OBJECT_INSTANCE_IMPL(${object.name});

JSValue ${object.name}::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  return JS_ThrowTypeError(ctx, "Illegal constructor");
}
${propSource.join('\n')}
${methodsSource.join('\n')}
${object.name}Instance::${object.name}Instance(${object.name} *element): ElementInstance(element, "CanvasElement", true) {}
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

export function generateCppSource(blob: Blob) {
  let sources = blob.objects.map(o => generateObjectSource(o));
  return `/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "${blob.filename}.h"
#include "bridge_qjs.h"

namespace kraken::binding::qjs {
  ${sources.join('')}
}`;
}
