import {Blob} from "./blob";
import {
  ClassObject,
  FunctionArguments,
  FunctionArgumentType,
  FunctionDeclaration,
  FunctionObject,
  ReturnType
} from "./declaration";
import {addIndent, getClassName} from "./utils";

enum PropType {
  hostObject,
  Element,
  Event
}

function generateMethodArgumentsCheck(m: FunctionDeclaration, object: ClassObject | FunctionObject) {
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

function generateTypeConverter(type: FunctionArgumentType | FunctionArgumentType[]): string {
  if (Array.isArray(type)) {
    return `TSSequence<${generateTypeConverter(type[0])}>`;
  }

  switch(type) {
    case FunctionArgumentType.int32:
      return `TSInt32`;
    case FunctionArgumentType.double:
      return `TSDouble`;
    case FunctionArgumentType.function:
      return `TSCallback`;
    case FunctionArgumentType.boolean:
      return `TSBoolean`;
    case FunctionArgumentType.string:
      return `TSDOMString`;
    case FunctionArgumentType.object:
      return `TSObject`;
    default:
    case FunctionArgumentType.any:
      return `TSAny`;
  }
}

function generateFunctionValueInit(object: FunctionObject) {
  function generateRequiredInitBody(argument: FunctionArguments, argsIndex: number) {
    let type = generateTypeConverter(argument.type);
    return `auto&& args_${argument.name} = Converter<${type}>::FromValue(ctx, argv[${argsIndex}], exception_state);`;
  }

  function generateInitBody(argument: FunctionArguments, argsIndex: number) {
    function generateInitParams(type: FunctionArgumentType | FunctionArgumentType[]) {
      if (type == FunctionArgumentType.any) {
        return 'ctx';
      }
      return '';
    }

      return `Converter<TSOptional<${generateTypeConverter(argument.type)}>>::ImplType args_${argument.name}{${generateInitParams(argument.type)}};
if (argc > ${argsIndex}) {
  args_${argument.name} = Converter<TSOptional<${generateTypeConverter(argument.type)}>>::FromValue(ctx, argv[${argsIndex}], exception_state);
}`
  }

  return object.declare.args.map((a, i) => {
    let body = a.required ? generateRequiredInitBody(a, i) : generateInitBody(a, i);
    return addIndent(body, 2);
  });
}

function generateCoreModuleCall(blob: Blob, object: FunctionObject) {
  let params = object.declare.args.map(a => `args_${a.name}`);
  let coreClassName = getClassName(blob);
  let returnValue = '';

  if (object.declare.returnType != ReturnType.void) {
    returnValue = 'ScriptValue returnValue = '
  }

  return addIndent(`
auto context = static_cast<ExecutingContext*>(JS_GetContextOpaque(ctx));
ExceptionState exception;

${returnValue}${coreClassName}::${object.declare.name}(context, ${params.join(', ')}, exception);

if (exception.HasException()) {
  return exception.ToQuickJS();
}
${returnValue ? 'return returnValue.ToQuickJS();' : 'return JS_NULL; '}`, 2);
}

function generateFunctionSource(blob: Blob, object: FunctionObject) {
  let paramCheck = generateMethodArgumentsCheck(object.declare, object);
  let varInit = generateFunctionValueInit(object);
  let moduleCall = generateCoreModuleCall(blob, object);
  return `static JSValue ${object.declare.name}(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
${paramCheck}
  ExceptionState exception_state;

${varInit.join('\n')}
${moduleCall}
}`;
}

export function generateCppSource(blob: Blob) {
  let installList: string[] = [];

  let sources = blob.objects.map(o => {
    if (o instanceof FunctionObject) {
      installList.push(` {"${o.declare.name}", ${o.declare.name}, ${o.declare.args.length}},`);
      return generateFunctionSource(blob, o);
    }
    return '';
  });

  return `/*
 * Copyright (C) 2021 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#include "${blob.filename}.h"
#include "bindings/qjs/member_installer.h"
#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/converter_impl.h"
#include "core/executing_context.h"
#include "core/${blob.implement}.h"

namespace kraken {

${sources.join('\n')}

void QJS${getClassName(blob)}::Install(ExecutingContext* context) {
  InstallGlobalFunctions(context);
}

void QJS${getClassName(blob)}::InstallGlobalFunctions(ExecutingContext* context) {
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    ${installList.join('\n')}
  };

  MemberInstaller::InstallFunctions(context, context->Global(), functionConfig);
}
}`;
}
