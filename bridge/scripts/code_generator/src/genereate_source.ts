import {Blob} from "./blob";
import {
  ClassObject,
  FunctionArguments,
  FunctionArgumentType,
  FunctionDeclaration,
  FunctionObject,
  PropsDeclaration,
} from "./declaration";
import {addIndent, getClassName} from "./utils";
import {ParameterType} from "./analyzer";

enum PropType {
  hostObject,
  Element,
  Event
}

function generateMethodArgumentsCheck(m: FunctionDeclaration) {
  if (m.args.length == 0) return '';

  let requiredArgsCount = 0;
  m.args.forEach(m => {
    if (m.required) requiredArgsCount++;
  });

  return `  if (argc < ${requiredArgsCount}) {
    return JS_ThrowTypeError(ctx, "Failed to execute '${m.name}' : ${requiredArgsCount} argument required, but %d present.", argc);
  }
`;
}

function generateTypeConverter(type: ParameterType[]): string {
  let haveNull = type.some(t => t === FunctionArgumentType.null);
  let returnValue = '';

  if (type[0] === FunctionArgumentType.array) {
    returnValue = `IDLSequence<${generateTypeConverter(type.slice(1))}>`;
  } else if (typeof type[0] === 'string') {
    returnValue = type[0];
  } else {
    switch(type[0]) {
      case FunctionArgumentType.int32:
        returnValue = `IDLInt32`;
        break;
      case FunctionArgumentType.int64:
        returnValue = 'IDLInt64';
        break;
      case FunctionArgumentType.double:
        returnValue = `IDLDouble`;
        break;
      case FunctionArgumentType.function:
        returnValue =  `IDLCallback`;
        break;
      case FunctionArgumentType.boolean:
        returnValue = `IDLBoolean`;
        break;
      case FunctionArgumentType.dom_string:
        returnValue = `IDLDOMString`;
        break;
      case FunctionArgumentType.object:
        returnValue = `IDLObject`;
        break;
      default:
      case FunctionArgumentType.any:
        returnValue = `IDLAny`;
        break;
    }
  }

  if (haveNull) {
    returnValue = `IDLNullable<${returnValue}>`;
  }

  return returnValue;
}

function generateRequiredInitBody(argument: FunctionArguments, argsIndex: number) {
  let type = generateTypeConverter(argument.type);
  return `auto&& args_${argument.name} = Converter<${type}>::FromValue(ctx, argv[${argsIndex}], exception_state);`;
}

function generateCallMethodName(name: string) {
  if (name === 'constructor') return 'Create';
  return name;
}

function generateOptionalInitBody(blob: Blob, declare: FunctionDeclaration, argument: FunctionArguments, argsIndex: number, previousArguments: string[], options: GenFunctionBodyOptions) {
  let call = '';
  let returnValueAssignment = '';
  if (declare.returnType[0] != FunctionArgumentType.void) {
    returnValueAssignment = 'return_value =';
  }
  if (options.isInstanceMethod) {
    call = `auto* self = toScriptWrappable<${getClassName(blob)}>(this_val);
${returnValueAssignment} self->${generateCallMethodName(declare.name)}(${[...previousArguments, `args_${argument.name}`, 'exception_state'].join(',')});`;
  } else {
    call = `${returnValueAssignment} ${getClassName(blob)}::${generateCallMethodName(declare.name)}(context, ${[...previousArguments, `args_${argument.name}`].join(',')}, exception_state);`;
  }


  return `auto&& args_${argument.name} = Converter<IDLOptional<${generateTypeConverter(argument.type)}>>::FromValue(ctx, argv[${argsIndex}], exception_state);
if (exception_state.HasException()) {
  return exception_state.ToQuickJS();
}

if (argc <= ${argsIndex + 1}) {
  ${call}
  break;
}`;
}

function generateFunctionCallBody(blob: Blob, declaration: FunctionDeclaration, options: GenFunctionBodyOptions = {isConstructor: false, isInstanceMethod: false}) {
  let minimalRequiredArgc = 0;
  declaration.args.forEach(m => {
    if (m.required) minimalRequiredArgc++;
  });

  let requiredArguments: string[] = [];
  let requiredArgumentsInit: string[] = [];
  if (minimalRequiredArgc > 0) {
    requiredArgumentsInit = declaration.args.filter((a, i) => a.required).map((a, i) => {
      requiredArguments.push(`args_${a.name}`);
      return generateRequiredInitBody(a, i);
    });
  }

  let optionalArgumentsInit: string[] = [];
  let totalArguments: string[] = requiredArguments.slice();

  for (let i = minimalRequiredArgc; i < declaration.args.length; i ++) {
    optionalArgumentsInit.push(generateOptionalInitBody(blob, declaration, declaration.args[i], i, totalArguments, options));
    totalArguments.push(`args_${declaration.args[i].name}`);
  }

  requiredArguments.push('exception_state');

  let call = '';
  let returnValueAssignment = '';
  if (declaration.returnType[0] != FunctionArgumentType.void) {
    returnValueAssignment = 'return_value =';
  }
  if (options.isInstanceMethod) {
    call = `auto* self = toScriptWrappable<${getClassName(blob)}>(this_val);
${returnValueAssignment} self->${generateCallMethodName(declaration.name)}(${minimalRequiredArgc > 0 ? `${requiredArguments.join(',')}` : 'exception_state'});`;
  } else {
    call = `${returnValueAssignment} ${getClassName(blob)}::${generateCallMethodName(declaration.name)}(context${minimalRequiredArgc > 0 ? `,${requiredArguments.join(',')}` : ''});`;
  }

  return `${requiredArgumentsInit.join('\n')}
if (argc <= ${minimalRequiredArgc}) {
  ${call}
  break;
}

${optionalArgumentsInit.join('\n')}
`;
}

function generateGlobalFunctionSource(blob: Blob, object: FunctionObject) {
  let body = generateFunctionBody(blob, object.declare);
  return `static JSValue ${object.declare.name}(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
${body}
}`;
}

function generateReturnValueInit(blob: Blob, type: ParameterType[], options: GenFunctionBodyOptions = {isConstructor: false, isInstanceMethod: false}) {
  if (type[0] == FunctionArgumentType.void) return '';

  if (options.isConstructor) {
    return `${getClassName(blob)}* return_value = nullptr;`
  }
  if (typeof type[0] === 'string') {
    if (type[0] === 'Promise') {
      return 'ScriptPromise return_value;';
    } else {
      return `${type[0]}* return_value = nullptr;`;
    }
  }
  return `Converter<${generateTypeConverter(type)}>::ImplType return_value;`;
}

function generateReturnValueResult(blob: Blob, type: ParameterType[], options: GenFunctionBodyOptions = {isConstructor: false, isInstanceMethod: false}): string {
  if (type[0] == FunctionArgumentType.void) return 'JS_NULL';
  if (options.isConstructor) {
    return `return_value->ToQuickJS()`;
  }

  if (typeof type[0] === 'string') {
    if (type[0] === 'Promise') {
      return 'return_value.ToQuickJS()';
    } else {
      return `return_value->ToQuickJS()`;
    }
  }

  return `Converter<${generateTypeConverter(type)}>::ToValue(ctx, std::move(return_value))`;
}

type GenFunctionBodyOptions = {isConstructor?: boolean, isInstanceMethod?: boolean};

function generateFunctionBody(blob: Blob, declare: FunctionDeclaration, options: GenFunctionBodyOptions = {isConstructor: false, isInstanceMethod : false}) {
  let paramCheck = generateMethodArgumentsCheck(declare);
  let callBody = generateFunctionCallBody(blob, declare, options);
  let returnValueInit = generateReturnValueInit(blob, declare.returnType, options);
  let returnValueResult = generateReturnValueResult(blob, declare.returnType, options);

  return `${paramCheck}

  ExceptionState exception_state;
  ${returnValueInit}
  ExecutingContext* context = ExecutingContext::From(ctx);

  do {  // Dummy loop for use of 'break'.
${addIndent(callBody, 4)}
  } while (false);

  if (exception_state.HasException()) {
    return exception_state.ToQuickJS();
  }
  return ${returnValueResult};
`;
}

function generateClassConstructorCallback(blob: Blob, declare: FunctionDeclaration) {
  return `JSValue QJS${getClassName(blob)}::ConstructorCallback(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv, int flags) {
${generateFunctionBody(blob, declare, {isConstructor: true})}
}
`;
}

function generatePropertyGetterCallback(blob: Blob, prop: PropsDeclaration) {
  return `static JSValue ${prop.name}AttributeGetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* ${blob.filename} = toScriptWrappable<${getClassName(blob)}>(this_val);
  assert(${blob.filename} != nullptr);
  return Converter<${generateTypeConverter(prop.type)}>::ToValue(ctx, ${blob.filename}->${prop.name}());
}`;
}

function generatePropertySetterCallback(blob: Blob, prop: PropsDeclaration) {
  return `static JSValue ${prop.name}AttributeSetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* ${blob.filename} = toScriptWrappable<${getClassName(blob)}>(this_val);
  ExceptionState exception_state;
  auto&& v = Converter<${generateTypeConverter(prop.type)}>::FromValue(ctx, argv[0], exception_state);
  if (exception_state.HasException()) {
    return exception_state.ToQuickJS();
  }
  ${blob.filename}->set${prop.name[0].toUpperCase() + prop.name.slice(1)}(v);
}`;
}

function generateMethodCallback(blob: Blob, methods: FunctionDeclaration[]): string[] {
  return methods.map(method => {
    return `static JSValue ${method.name}(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
    ${ generateFunctionBody(blob, method, {isInstanceMethod: true}) }
}`;
  });
}

function generateClassSource(blob: Blob, object: ClassObject) {
  let constructorCallback = '';
  if (object.construct) {
    constructorCallback = generateClassConstructorCallback(blob, object.construct);
  }
  let getterCallbacks: string[] = [];
  let setterCallbacks: string[] = [];
  let methodCallback = generateMethodCallback(blob, object.methods);

  object.props.forEach(prop => {
    getterCallbacks.push(generatePropertyGetterCallback(blob, prop));
    if (!prop.readonly) {
      setterCallbacks.push(generatePropertySetterCallback(blob, prop))
    }
  });

  return [
    constructorCallback,
    getterCallbacks.join('\n'),
    setterCallbacks.join('\n'),
    methodCallback.join('\n')
  ].join('\n');
}

function generateInstallGlobalFunctions(blob: Blob, installList: string[]) {
  return `void QJS${getClassName(blob)}::InstallGlobalFunctions(ExecutingContext* context) {
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    ${installList.join(',\n')}
  };

  MemberInstaller::InstallFunctions(context, context->Global(), functionConfig);
}`;
}

function generateConstructorInstaller(blob: Blob) {
  return `void QJS${getClassName(blob)}::InstallConstructor(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue constructor = context->contextData()->constructorForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributeConfig {
    {"${getClassName(blob)}", nullptr, nullptr, constructor}
  };
  MemberInstaller::InstallAttributes(context, context->Global(), attributeConfig);
}`;
}

function generatePrototypeMethodsInstaller(blob: Blob, installList: string[]) {
  return `void QJS${getClassName(blob)}::InstallPrototypeMethods(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributesConfig {
    ${installList.join(',\n')}
  };

  MemberInstaller::InstallAttributes(context, prototype, attributesConfig);
}
`;
}

function generatePrototypePropsInstaller(blob: Blob, installList: string[]) {
  return `void QJS${getClassName(blob)}::InstallPrototypeProperties(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    ${installList.join(',\n')}
  };

  MemberInstaller::InstallFunctions(context, prototype, functionConfig);
}
`;
}

export function generateCppSource(blob: Blob) {
  let functionInstallList: string[] = [];
  let classMethodsInstallList: string[] = [];
  let classPropsInstallList: string[] = [];
  let wrapperTypeInfoInit = '';

  let sources = blob.objects.map(o => {
    if (o instanceof FunctionObject) {
      functionInstallList.push(` {"${o.declare.name}", ${o.declare.name}, ${o.declare.args.length}}`);
      return generateGlobalFunctionSource(blob, o);
    } else {
      o.props.forEach(prop => {
        classMethodsInstallList.push(`{"${prop.name}", ${prop.name}AttributeGetCallback, ${prop.readonly ? 'nullptr' : `${prop.name}AttributeSetCallback`}}`)
      });
      o.methods.forEach(method => {
        classPropsInstallList.push(`{"${method.name}", ${method.name}, ${method.args.length}}`)
      });
      wrapperTypeInfoInit = `const WrapperTypeInfo& ${getClassName(blob)}::wrapper_type_info_ = QJS${getClassName(blob)}::m_wrapperTypeInfo;`;
      return generateClassSource(blob, o);
    }
  });

  let haveInterfaceDefine = !!blob.objects.find(object => object instanceof ClassObject);

  return `/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "${blob.filename}.h"
#include "bindings/qjs/member_installer.h"
#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/converter_impl.h"
#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/script_promise.h"
#include "core/executing_context.h"

namespace kraken {

${wrapperTypeInfoInit}

${sources.join('\n')}

void QJS${getClassName(blob)}::Install(ExecutingContext* context) {
  InstallGlobalFunctions(context);
  ${haveInterfaceDefine ? `InstallConstructor(context);
  InstallPrototypeMethods(context);
  InstallPrototypeProperties(context)` : ''};
}

${generateInstallGlobalFunctions(blob, functionInstallList)}

${haveInterfaceDefine ? `${generateConstructorInstaller(blob)}
${generatePrototypeMethodsInstaller(blob, classMethodsInstallList)}
${generatePrototypePropsInstaller(blob, classPropsInstallList)}` : ''}
}`;
}
