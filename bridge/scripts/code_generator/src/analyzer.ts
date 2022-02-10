import ts, {HeritageClause, ScriptTarget, VariableStatement} from 'typescript';
import {Blob} from './blob';
import {
  ClassObject,
  FunctionArguments,
  FunctionArgumentType,
  FunctionDeclaration,
  FunctionObject,
  PropsDeclaration,
  PropsDeclarationKind,
  ReturnType
} from './declaration';
import {generatorSource} from './generator';

export function analyzer(blob: Blob) {
  let code = blob.raw;
  const sourceFile = ts.createSourceFile(blob.source, blob.raw, ScriptTarget.ES2020);
  blob.objects = sourceFile.statements.map(statement => walkProgram(statement)).filter(o => {
    return o instanceof ClassObject || o instanceof FunctionObject;
  }) as (FunctionObject | ClassObject)[];
  return generatorSource(blob);
}

function getInterfaceName(statement: ts.Statement) {
  return (statement as ts.InterfaceDeclaration).name.escapedText;
}

function getHeritageType(heritage: HeritageClause) {
  let expression = heritage.types[0].expression;
  if (expression.kind === ts.SyntaxKind.Identifier) {
    return (expression as ts.Identifier).escapedText;
  }
  return null;
}

function getPropKind(type: ts.TypeNode): PropsDeclarationKind {
  if (type.kind === ts.SyntaxKind.StringKeyword) {
    return PropsDeclarationKind.string;
  } else if (type.kind === ts.SyntaxKind.NumberKeyword) {
    return PropsDeclarationKind.double;
  } else if (type.kind === ts.SyntaxKind.BooleanKeyword) {
    return PropsDeclarationKind.boolean;
  } else if (type.kind === ts.SyntaxKind.FunctionType) {
    return PropsDeclarationKind.function;
  } else if (type.kind === ts.SyntaxKind.TypeReference) {
    // @ts-ignore
    let typeName = (type as ts.TypeReference).typeName;
    if (typeName.escapedText === 'int64') {
      return PropsDeclarationKind.int64;
    }
  }
  return PropsDeclarationKind.object;
}

function getFunctionReturnType(keyword: ts.TypeNode): ReturnType {
  switch (keyword.kind) {
    case ts.SyntaxKind.VoidKeyword:
      return ReturnType.void;
  }
  return ReturnType.null;
}

function getPropName(propName: ts.PropertyName) {
  if (propName.kind == ts.SyntaxKind.Identifier) {
    return propName.escapedText.toString();
  } else if (propName.kind === ts.SyntaxKind.StringLiteral) {
    return propName.text;
  } else if (propName.kind === ts.SyntaxKind.NumericLiteral) {
    return propName.text;
  }
  throw new Error(`prop name: ${ts.SyntaxKind[propName.kind]} is not supported`);
}

function getParameterName(name: ts.BindingName) : string {
  if (name.kind === ts.SyntaxKind.Identifier) {
    return name.escapedText.toString();
  }
  return  '';
}

function getParameterType(type: ts.TypeNode) {
  if (type.kind === ts.SyntaxKind.StringKeyword) {
    return FunctionArgumentType.string;
  } else if (type.kind === ts.SyntaxKind.NumberKeyword) {
    return FunctionArgumentType.number;
  } else if (type.kind === ts.SyntaxKind.BooleanKeyword) {
    return FunctionArgumentType.boolean;
  } else if (type.kind === ts.SyntaxKind.TypeReference) {
    let typeReference: ts.TypeReference = type as unknown as ts.TypeReference;
    // @ts-ignore
    let identifier = (typeReference.typeName as ts.Identifier).text;
    if (identifier === 'Function') {
      return FunctionArgumentType.function;
    }
  }
  return FunctionArgumentType.union;
}

function paramsNodeToArguments(parameter: ts.ParameterDeclaration): FunctionArguments {
  let args = new FunctionArguments();
  args.name = getParameterName(parameter.name);
  args.type = getParameterType(parameter.type!);
  args.required = !parameter.questionToken;
  return args;
}

function isParamsReadOnly(m: ts.PropertySignature): boolean {
  if (!m.modifiers) return false;
  return m.modifiers.some(k => k.kind === ts.SyntaxKind.ReadonlyKeyword);
}

function walkProgram(statement: ts.Statement) {
  switch(statement.kind) {
    case ts.SyntaxKind.InterfaceDeclaration: {
      let interfaceName = getInterfaceName(statement);
      if (interfaceName === 'HostObject' || interfaceName === 'HostClass' || interfaceName === 'Element' || interfaceName === 'Event') return;
      let s = (statement as ts.InterfaceDeclaration);
      let obj = new ClassObject();
      if (s.heritageClauses) {
        let heritage = s.heritageClauses[0];
        let heritageType = getHeritageType(heritage);
        if (heritageType) obj.type = heritageType.toString();
      }

      obj.name = s.name.escapedText.toString();

      s.members.forEach(member => {
        switch(member.kind) {
          case ts.SyntaxKind.PropertySignature: {
            let prop = new PropsDeclaration();
            let m = (member as ts.PropertySignature);
            prop.name = getPropName(m.name);
            prop.readonly = isParamsReadOnly(m);

            let propKind = m.type;
            if (propKind) {
              prop.kind = getPropKind(propKind);
              if (prop.kind === PropsDeclarationKind.function) {
                let f = (m.type as ts.FunctionTypeNode);
                let functionProps = prop as FunctionDeclaration;
                functionProps.args = [];
                f.parameters.forEach(params => {
                  let p = paramsNodeToArguments(params);
                  functionProps.args.push(p);
                });
                obj.methods.push(functionProps);
              } else {
                obj.props.push(prop);
              }
            }

            break;
          }
          case ts.SyntaxKind.MethodSignature: {
            let m = (member as ts.MethodSignature);
            let f = new FunctionDeclaration();
            f.name = getPropName(m.name);
            f.kind = PropsDeclarationKind.function;
            f.args = [];
            m.parameters.forEach(params => {
              let p = paramsNodeToArguments(params);
              f.args.push(p);
            });
            obj.methods.push(f);
          }
        }
      });

      return obj;
    }
    case ts.SyntaxKind.VariableStatement: {
      let declaration = (statement as VariableStatement).declarationList.declarations[0];
      let methodName = (declaration.name as ts.Identifier).text;
      let type = declaration.type;
      let functionObject = new FunctionObject();

      functionObject.declare = new FunctionDeclaration();
      if (type?.kind == ts.SyntaxKind.FunctionType) {
        functionObject.declare.args = (type as ts.FunctionTypeNode).parameters.map(param => paramsNodeToArguments(param));
        functionObject.declare.returnType = getFunctionReturnType((type as ts.FunctionTypeNode).type);
        functionObject.declare.name = methodName.toString();
      }

      return functionObject;
    }
  }

  return null;
}
