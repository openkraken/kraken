import {Blob} from "./blob";
import {
  ClassObject,
  FunctionArguments,
  FunctionDeclaration,
  PropsDeclaration,
  PropsDeclarationKind
} from "./declaration";
import {addIndent} from "./utils";

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
  Element,
  Event
}

function getPropsVars(object: ClassObject, type: PropType) {
  let classSubFix = object.name;
  if (type == PropType.Element || type == PropType.Event) {
    classSubFix += 'Instance';
  }

  let instanceName = '';
  let classId = '';
  if (type == PropType.hostObject) {
    instanceName = 'object';
    classId = 'JSContext::kHostObjectClassId';
  } else if (type == PropType.Element) {
    instanceName = 'element';
    classId = 'Element::classId()';
  } else if (type == PropType.Event) {
    instanceName = 'event';
    classId = 'Event::kEventClassID';
  }

  return {
    classSubFix,
    classId,
    instanceName
  };
}

function generatePropsGetter(object: ClassObject, type: PropType, p: PropsDeclaration) {
  let {
    classId,
    classSubFix,
    instanceName
  } = getPropsVars(object, type);


  let getterCode = '';
  if (object.type === 'Event') {
    let qjsCallFunc = '';
    if (p.kind === PropsDeclarationKind.double) {
      qjsCallFunc = `JS_NewFloat64(ctx, nativeEvent->${p.name})`;
    } else if (p.kind === PropsDeclarationKind.boolean) {
      qjsCallFunc = `JS_NewBool(ctx, nativeEvent->${p.name} ? 1 : 0)`;
    } else if (p.kind === PropsDeclarationKind.string) {
      qjsCallFunc = `JS_NewUnicodeString(event->m_context->runtime(), ctx, nativeEvent->${p.name}->string, nativeEvent->${p.name}->length);`;
    } else if (p.kind === PropsDeclarationKind.int64) {
      qjsCallFunc = `JS_NewUint32(ctx, nativeEvent->${p.name});`
    }

    getterCode = `auto *${instanceName} = static_cast<${classSubFix} *>(JS_GetOpaque(this_val, ${classId}));
  auto *nativeEvent = reinterpret_cast<Native${object.name} *>(event->nativeEvent);
  return ${qjsCallFunc};`;
  } else {
    getterCode = `auto *${instanceName} = static_cast<${classSubFix} *>(JS_GetOpaque(this_val, ${classId}));
  return ${instanceName}->callNativeMethods("get${p.name[0].toUpperCase() + p.name.substring(1)}", 0, nullptr);`;
  }

  let flushUICommandCode = '';
  if (object.type === 'Element' || object.type === 'HostObject') {
    flushUICommandCode = 'getDartMethod()->flushUICommand();'
  }

  return `PROP_GETTER(${classSubFix}, ${p.name})(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  ${flushUICommandCode}
  ${getterCode}
}`;
}

function generatePropsSetter(object: ClassObject, type: PropType, p: PropsDeclaration) {
  let {
    classId,
    classSubFix,
    instanceName
  } = getPropsVars(object, type);

  if (p.readonly) {
    return `PROP_SETTER(${classSubFix}, ${p.name})(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  return JS_NULL;
}`;
  }

  return `PROP_SETTER(${classSubFix}, ${p.name})(QjsContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *${instanceName} = static_cast<${classSubFix} *>(JS_GetOpaque(this_val, ${classId}));
  NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return ${instanceName}->callNativeMethods("set${p.name[0].toUpperCase() + p.name.substring(1)}", 1, arguments);
}`;
}

function generatePropsSource(object: ClassObject, type: PropType) {
  let propSource: string[] = [];
  if (object.props.length > 0) {
    object.props.forEach(p => {
      let getter = generatePropsGetter(object, type, p);
      let setter = generatePropsSetter(object, type, p);
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
  for (let i = 0; i < requiredArgsCount; i++) {
    argsCheck.push(generateArgumentsTypeCheck(i, m.args[i], m));
  }

  return `  if (argc < ${requiredArgsCount}) {
    return JS_ThrowTypeError(ctx, "Failed to execute '${m.name}' on '${object.name}': ${requiredArgsCount} argument required, but %d present.", argc);
  }
  ${argsCheck.join('\n  ')}
`;
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
          for (let i = 0; i < m.args.length; i++) {
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
        for (let i = 0; i < allConditions.length; i++) {
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

function generateEventConstructorCode(object: ClassObject) {
  return `if (argc < 1) {
    return JS_ThrowTypeError(ctx, "Failed to construct '${object.name}': 1 argument required, but only 0 present.");
  }

  JSValue eventTypeValue = argv[0];
  JSValue eventInitValue = JS_NULL;

  if (argc == 2) {
    eventInitValue = argv[1];
  }

  auto *nativeEvent = new Native${object.name}();
  nativeEvent->nativeEvent.type = jsValueToNativeString(ctx, eventTypeValue);

  auto event = new ${object.name}Instance(this, reinterpret_cast<NativeEvent *>(nativeEvent), eventInitValue);
  return event->instanceObject;`;
}

function generateEventInstanceConstructorCode(object: ClassObject) {
  let atomCreateCode: string[] = [];
  let atomReleaseCode: string[] = [];
  let propWriteCode: string[] = [];

  object.props.forEach(p => {
    atomCreateCode.push(`JSAtom ${p.name}Atom = JS_NewAtom(m_ctx, "${p.name}");`)
    atomReleaseCode.push(`JS_FreeAtom(m_ctx, ${p.name}Atom);`)

    let propApplyCode = '';
    if (p.kind === PropsDeclarationKind.boolean) {
      propApplyCode = `ne->${p.name} = JS_ToBool(m_ctx, JS_GetProperty(m_ctx, eventInit, ${p.name}Atom)) ? 1 : 0;`;
    } else if (p.kind === PropsDeclarationKind.int64) {
      propApplyCode = `JS_ToUint32(m_ctx, reinterpret_cast<uint32_t *>(&ne->${p.name}), JS_GetProperty(m_ctx, eventInit, ${p.name}Atom));`
    } else if (p.kind === PropsDeclarationKind.string) {
      propApplyCode = addIndent(`JSValue v = JS_GetProperty(m_ctx, eventInit, ${p.name}Atom);
  ne->${p.name} = jsValueToNativeString(m_ctx, v);`, 0);
    } else if (p.kind === PropsDeclarationKind.double) {
      propApplyCode = `JS_ToFloat64(m_ctx, &ne->${p.name}, JS_GetProperty(m_ctx, eventInit, ${p.name}Atom));`;
    }

    propWriteCode.push(addIndent(`if (JS_HasProperty(m_ctx, eventInit, ${p.name}Atom)) {
  ${propApplyCode}
}`, 4));
  });

  return `if (JS_IsObject(eventInit)) {
${addIndent(atomCreateCode.join('\n'), 4)}
    auto *ne = reinterpret_cast<Native${object.name} *>(nativeEvent);

${propWriteCode.join('\n')}

${addIndent(atomReleaseCode.join('\n'), 4)}
  }`;
}

function generateHostClassSource(object: ClassObject) {
  let propSource: string[] = generatePropsSource(object, object.type === 'Event' ? PropType.Event : PropType.Element);
  let methodsSource: string[] = generateMethodsSource(object, object.type === 'Event' ? PropType.Event : PropType.Element);
  let constructorCode = '';
  if (object.type === 'Element') {
    constructorCode = 'return JS_ThrowTypeError(ctx, "Illegal constructor");';
  } else if (object.type === 'Event') {
    constructorCode = generateEventConstructorCode(object);
  }

  let instanceConstructorCode = '';
  if (object.type === 'Event') {
    instanceConstructorCode = `${object.name}Instance::${object.name}Instance(${object.name} *${object.type.toLowerCase()}, NativeEvent *nativeEvent, JSValue eventInit): ${object.type}Instance(${object.type.toLowerCase()}, nativeEvent) {
  ${generateEventInstanceConstructorCode(object)}
}`
  } else {
    instanceConstructorCode = `${object.name}Instance::${object.name}Instance(${object.name} *${object.type.toLowerCase()}): ${object.type}Instance(${object.type.toLowerCase()}, "${object.name}", true) {}`;
  }

  let globalBindingName = '';
  if (object.type === 'Element') {
    globalBindingName = `HTML${object.name}`;
  } else {
    globalBindingName = object.name;
  }

  return `
${object.name}::${object.name}(JSContext *context) : ${object.type}(context) {}

void bind${object.name}(std::unique_ptr<JSContext> &context) {
  auto *constructor = ${object.name}::instance(context.get());
  context->defineGlobalProperty("${globalBindingName}", constructor->classObject);
}

OBJECT_INSTANCE_IMPL(${object.name});

JSValue ${object.name}::constructor(QjsContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
  ${constructorCode}
}
${propSource.join('\n')}
${methodsSource.join('\n')}
${instanceConstructorCode}
`;
}

function generateObjectSource(object: ClassObject) {
  if (object.type === 'HostClass' || object.type === 'Element' || object.type === 'Event') {
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
#include "bindings/qjs/qjs_patch.h"

namespace kraken::binding::qjs {
  ${sources.join('')}
}`;
}
