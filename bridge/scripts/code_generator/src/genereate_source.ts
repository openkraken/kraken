import {Blob} from "./blob";
import {
  ClassObject,
  FunctionArguments,
  FunctionArgumentType,
  FunctionDeclaration,
  PropsDeclaration,
  PropsDeclarationKind
} from "./declaration";
import {addIndent} from "./utils";

function generateHostObjectSource(object: ClassObject) {
  let propSource: string[] = generatePropsSource(object, PropType.hostObject);
  let methodsSource: string[] = generateMethodsSource(object, PropType.hostObject);
  return `${object.name}::${object.name}(ExecutionContext *context,
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
    static_cast<uint32_t>(methodString.size())
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
  let className = object.name;
  if (type == PropType.Element || type == PropType.Event) {
    classSubFix += 'Instance';
  }

  let instanceName = '';
  let classId = '';
  if (type == PropType.hostObject) {
    instanceName = 'object';
    classId = 'ExecutionContext::kHostObjectClassId';
  } else if (type == PropType.Element) {
    instanceName = 'element';
    classId = 'Element::classId()';
  } else if (type == PropType.Event) {
    instanceName = 'event';
    classId = 'Event::kEventClassID';
  }

  return {
    className,
    classSubFix,
    classId,
    instanceName
  };
}

function generatePropsGetter(object: ClassObject, type: PropType, p: PropsDeclaration) {
  let {
    classId,
    classSubFix,
    className,
    instanceName
  } = getPropsVars(object, type);


  let getterCode = '';
  if (object.type === 'Event') {
    let qjsCallFunc = '';
    if (p.kind === PropsDeclarationKind.double) {
      qjsCallFunc = `return JS_NewFloat64(ctx, nativeEvent->${p.name})`;
    } else if (p.kind === PropsDeclarationKind.boolean) {
      qjsCallFunc = `return JS_NewBool(ctx, nativeEvent->${p.name} ? 1 : 0)`;
    } else if (p.kind === PropsDeclarationKind.string) {
      qjsCallFunc = `return JS_NewUnicodeString(event->m_context->runtime(), ctx, nativeEvent->${p.name}->string, nativeEvent->${p.name}->length);`;
    } else if (p.kind === PropsDeclarationKind.int64) {
      qjsCallFunc = `return JS_NewUint32(ctx, nativeEvent->${p.name});`
    } else if (p.kind === PropsDeclarationKind.object) {
      qjsCallFunc = `std::u16string u16${p.name} = std::u16string(reinterpret_cast<const char16_t *>(nativeEvent->${p.name}->string), nativeEvent->${p.name}->length);
  std::string ${p.name} = toUTF8(u16${p.name});
  return JS_ParseJSON(ctx, ${p.name}.c_str(), ${p.name}.size(), "");`;
    }

    getterCode = `auto *${instanceName} = static_cast<${classSubFix} *>(JS_GetOpaque(this_val, ${classId}));
  auto *nativeEvent = reinterpret_cast<Native${object.name} *>(event->nativeEvent);
  ${qjsCallFunc};`;
  } else if (object.type === 'HostObject') {
    getterCode = `auto *${instanceName} = static_cast<${classSubFix} *>(JS_GetOpaque(this_val, ${classId}));
  return ${instanceName}->callNativeMethods("get${p.name[0].toUpperCase() + p.name.substring(1)}", 0, nullptr);`;
  } else {
    getterCode = `auto *${instanceName} = static_cast<${classSubFix} *>(JS_GetOpaque(this_val, ${classId}));
  return ${instanceName}->getNativeProperty("${p.name}");`;
  }

  let flushUICommandCode = '';
  if (object.type === 'Element' || object.type === 'HostObject') {
    flushUICommandCode = 'getDartMethod()->flushUICommand();'
  }

  return `IMPL_PROPERTY_GETTER(${className}, ${p.name})(JSContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  ${flushUICommandCode}
  ${getterCode}
}`;
}

function generatePropsSetter(object: ClassObject, type: PropType, p: PropsDeclaration) {
  let {
    classId,
    classSubFix,
    className,
    instanceName
  } = getPropsVars(object, type);

  if (p.readonly) {
    return '';
  }

  let setterCode = '';
  if (object.type == 'Element') {
    setterCode = `std::string key = "${p.name}";
  std::unique_ptr<NativeString> args_01 = stringToNativeString(key);
  std::unique_ptr<NativeString> args_02 = jsValueToNativeString(ctx, argv[0]);
  element->m_context->uiCommandBuffer()
    ->addCommand(${instanceName}->m_eventTargetId, UICommand::setProperty, *args_01, *args_02, nullptr);
  return JS_NULL;`;
  } else {
    setterCode = `NativeValue arguments[] = {
    jsValueToNativeValue(ctx, argv[0])
  };
  return ${instanceName}->callNativeMethods("set${p.name[0].toUpperCase() + p.name.substring(1)}", 1, arguments);`;
  }


  return `IMPL_PROPERTY_SETTER(${className}, ${p.name})(JSContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  auto *${instanceName} = static_cast<${classSubFix} *>(JS_GetOpaque(this_val, ${classId}));
  ${setterCode}
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
  if (argv.type == FunctionArgumentType.string) {
    return `if (!JS_IsString(argv[${index}])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ${m.name}: ${index + 1}st arguments is not String.");
  }`;
  } else if (argv.type === FunctionArgumentType.number) {
    return `if (!JS_IsNumber(argv[${index}])) {
    return JS_ThrowTypeError(ctx, "Failed to execute ${m.name}: ${index + 1}st arguments is not Number.");
  }`
  } else if (argv.type === FunctionArgumentType.boolean) {
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

function generateDefaultNativeValue(m: FunctionArguments, index: number) {
  switch(m.type) {
    case FunctionArgumentType.boolean:
      return `NativeValue argv${index} = Native_NewBool(false);`;
    case FunctionArgumentType.number:
      return `NativeValue argv${index} = Native_NewFloat64(NAN);`;
    case FunctionArgumentType.string:
      return `NativeValue argv${index} = Native_NewCString("");`;
    default:
      return '';
  }
}

function generateMethodsSource(object: ClassObject, type: PropType) {
  let {
    classId,
    classSubFix,
    instanceName
  } = getPropsVars(object, type);

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
          let optionalArguments = [];
          for (let i = 0; i < m.args.length; i++) {
            if (m.args[i].required) {
              callArguments.push(` jsValueToNativeValue(ctx, argv[${i}])`);
            } else {
              optionalArguments.push(`${addIndent(generateDefaultNativeValue(m.args[i], i), 2)}
  if (argc == ${i + 1}) {
    argv${i} = jsValueToNativeValue(ctx, argv[${i}]);
  }`);
              callArguments.push(` argv${i}`);
            }
          }
          callArgumentsCode = `
${optionalArguments.join('\n  ')}
  NativeValue arguments[] = {
  ${callArguments.join(',\n  ')}
  };`;


        }

        return `${generateMethodArgumentsCheck(m, object)}
  getDartMethod()->flushUICommand();
${callArgumentsCode}
  auto *${instanceName} = static_cast<${classSubFix} *>(JS_GetOpaque(this_val, ${classId}));
  return ${instanceName}->callNativeMethods("${m.name}", ${m.args.length}, ${m.args.length > 0 ? 'arguments' : 'nullptr'});`;
      }

      if (polymorphism) {
        let allConditions = object.methods.filter(me => me.name === m.name);
        let caseCode = [];
        for (let i = 0; i < allConditions.length; i++) {
          caseCode.push(`case ${allConditions[i].args.length}: {
${addIndent(createMethodBody(allConditions[i]), 2)}
  }\n  `)
        }

        let polymorphismTemplate = `JSValue ${object.name}::${m.name}(JSContext *ctx, JSValue this_val, int argc, JSValue *argv) {
  switch(argc) {
  ${addIndent(caseCode.join(''), 2)}
  default:
    return JS_NULL;
  }
}`;
        methodsSource.push(polymorphismTemplate);
      } else {
        let body = createMethodBody(m);

        methodsSource.push(`JSValue ${object.name}::${m.name}(JSContext *ctx, JSValue this_val, int argc, JSValue *argv) {
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
  JSValue eventInit = JS_NULL;

  if (argc == 2) {
    eventInit = argv[1];
  }

  auto *nativeEvent = new Native${object.name}();
  nativeEvent->nativeEvent.type = jsValueToNativeString(ctx, eventTypeValue).release();

  ${generateEventInstanceConstructorCode(object)}

  auto event = new ${object.name}Instance(this, reinterpret_cast<NativeEvent *>(nativeEvent));
  return event->jsObject;`;
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
      propApplyCode = `nativeEvent->${p.name} = JS_ToBool(m_ctx, JS_GetProperty(m_ctx, eventInit, ${p.name}Atom)) ? 1 : 0;`;
    } else if (p.kind === PropsDeclarationKind.int64) {
      propApplyCode = `JS_ToInt32(m_ctx, reinterpret_cast<int32_t *>(&nativeEvent->${p.name}), JS_GetProperty(m_ctx, eventInit, ${p.name}Atom));`
    } else if (p.kind === PropsDeclarationKind.string) {
      propApplyCode = addIndent(`JSValue v = JS_GetProperty(m_ctx, eventInit, ${p.name}Atom);
  nativeEvent->${p.name} = jsValueToNativeString(m_ctx, v).release();
  JS_FreeValue(m_ctx, v);`, 0);
    } else if (p.kind === PropsDeclarationKind.double) {
      propApplyCode = `JS_ToFloat64(m_ctx, &nativeEvent->${p.name}, JS_GetProperty(m_ctx, eventInit, ${p.name}Atom));`;
    } else if (p.kind === PropsDeclarationKind.object) {
      propApplyCode = addIndent(`JSValue v = JS_GetProperty(m_ctx, eventInit, ${p.name}Atom);
  JSValue json = JS_JSONStringify(m_ctx, v, JS_NULL, JS_NULL);
  if (JS_IsException(json)) return json;
  nativeEvent->${p.name} = jsValueToNativeString(m_ctx, json).release();
  JS_FreeValue(m_ctx, json);
  JS_FreeValue(m_ctx, v);`, 0);
    }

    propWriteCode.push(addIndent(`if (JS_HasProperty(m_ctx, eventInit, ${p.name}Atom)) {
  ${propApplyCode}
}`, 4));
  });

  return `if (JS_IsObject(eventInit)) {
${addIndent(atomCreateCode.join('\n'), 4)}

${propWriteCode.join('\n')}

${addIndent(atomReleaseCode.join('\n'), 4)}
  }`;
}

function elementNameToTagName(name: string): string {
  switch(name) {
    case 'AnchorElement':
      return 'a';
    case 'CanvasElement':
      return 'canvas';
    case 'ImageElement':
      return 'img';
    case 'InputElement':
      return 'input';
    case 'ObjectElement':
      return 'object';
    case 'ScriptElement':
      return 'script';
    case 'SvgElement':
      return 'svg';
  }
  return name;
}

function generateHostClassSource(object: ClassObject) {
  let propSource: string[] = generatePropsSource(object, object.type === 'Event' ? PropType.Event : PropType.Element);
  let methodsSource: string[] = generateMethodsSource(object, object.type === 'Event' ? PropType.Event : PropType.Element);
  let constructorCode = '';
  if (object.type === 'Element') {
    constructorCode = `auto instance = new ${object.name}Instance(this);
  return instance->jsObject;`;
  } else if (object.type === 'Event') {
    constructorCode = generateEventConstructorCode(object);
  }

  let instanceConstructorCode = '';
  if (object.type === 'Event') {
    instanceConstructorCode = `${object.name}Instance::${object.name}Instance(${object.name} *${object.type.toLowerCase()}, NativeEvent *nativeEvent): ${object.type}Instance(${object.type.toLowerCase()}, nativeEvent) {}`
  } else {
    instanceConstructorCode = `${object.name}Instance::${object.name}Instance(${object.name} *${object.type.toLowerCase()}): ${object.type}Instance(${object.type.toLowerCase()}, "${elementNameToTagName(object.name)}", true) {}`;
  }

  let globalBindingName = '';
  if (object.type === 'Element') {
    globalBindingName = `HTML${object.name}`;
  } else {
    globalBindingName = object.name;
  }

  let specialBind = '';
  if (object.name === 'ImageElement') {
    specialBind = `context->defineGlobalProperty("Image", JS_DupValue(context->ctx(), constructor->jsObject));`
  }

  let classInheritCode = '';
  if (object.type === 'Element') {
    classInheritCode = 'JS_SetPrototype(m_ctx, m_prototypeObject, Element::instance(m_context)->prototype());';
  } else if (object.type === 'Event') {
    classInheritCode = 'JS_SetPrototype(m_ctx, m_prototypeObject, Event::instance(m_context)->prototype());';
  }

  return `
${object.name}::${object.name}(ExecutionContext *context) : ${object.type}(context) {
  ${classInheritCode}
}

void bind${object.name}(std::unique_ptr<ExecutionContext> &context) {
  auto *constructor = ${object.name}::instance(context.get());
  context->defineGlobalProperty("${globalBindingName}", constructor->jsObject);
  ${specialBind}
}

JSValue ${object.name}::instanceConstructor(JSContext *ctx, JSValue func_obj, JSValue this_val, int argc, JSValue *argv) {
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
#include "page.h"
#include "bindings/qjs/qjs_patch.h"

namespace kraken::binding::qjs {
  ${sources.join('')}
}`;
}
