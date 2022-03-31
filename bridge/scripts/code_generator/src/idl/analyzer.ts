import ts, {HeritageClause, ScriptTarget, VariableStatement} from 'typescript';
import {IDLBlob} from './IDLBlob';
import {
  ClassObject,
  ClassObjectKind,
  FunctionArguments,
  FunctionArgumentType,
  FunctionDeclaration,
  FunctionObject,
  PropsDeclaration,
} from './declaration';
import {generatorSource} from './generator';

export function analyzer(blob: IDLBlob) {
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

export type ParameterType =  FunctionArgumentType | string;

function getParameterBaseType(type: ts.TypeNode): ParameterType {
  if (type.kind === ts.SyntaxKind.StringKeyword) {
    return FunctionArgumentType.dom_string;
  } else if (type.kind === ts.SyntaxKind.NumberKeyword) {
    return FunctionArgumentType.double;
  } else if (type.kind === ts.SyntaxKind.BooleanKeyword) {
    return FunctionArgumentType.boolean;
  } else if (type.kind === ts.SyntaxKind.AnyKeyword) {
    return FunctionArgumentType.any;
  } else if (type.kind === ts.SyntaxKind.ObjectKeyword) {
    return FunctionArgumentType.object;
    // @ts-ignore
  } else if (type.kind === ts.SyntaxKind.VoidKeyword) {
    return FunctionArgumentType.void;
  } else if (type.kind === ts.SyntaxKind.NullKeyword) {
    return FunctionArgumentType.null;
  } else if (type.kind === ts.SyntaxKind.UndefinedKeyword) {
    return FunctionArgumentType.undefined;
  } else if (type.kind === ts.SyntaxKind.TypeReference) {
    let typeReference: ts.TypeReference = type as unknown as ts.TypeReference;
    // @ts-ignore
    let identifier = (typeReference.typeName as ts.Identifier).text;
    if (identifier === 'Function') {
      return FunctionArgumentType.function;
    } else if (identifier === 'int32') {
      return FunctionArgumentType.int32;
    } else if (identifier === 'int64') {
      return FunctionArgumentType.int64;
    } else if (identifier === 'double') {
      return FunctionArgumentType.double;
    }

    return identifier;
  } else if (type.kind === ts.SyntaxKind.LiteralType) {
    // @ts-ignore
    return getParameterBaseType((type as ts.LiteralTypeNode).literal);
  }

  return FunctionArgumentType.any;
}

function getParameterType(type: ts.TypeNode): ParameterType[] {
  if (type.kind == ts.SyntaxKind.ArrayType) {
    let arrayType = type as unknown as ts.ArrayTypeNode;
    return [FunctionArgumentType.array, getParameterBaseType(arrayType.elementType)];
  } else if (type.kind === ts.SyntaxKind.UnionType) {
    let node = type as unknown as ts.UnionType;
    let types = node.types;
    // @ts-ignore
    return types.map(type => getParameterBaseType(type as unknown as ts.TypeNode));
  }
  return [getParameterBaseType(type)];
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
      let s = (statement as ts.InterfaceDeclaration);
      let obj = new ClassObject();
      if (s.heritageClauses) {
        let heritage = s.heritageClauses[0];
        let heritageType = getHeritageType(heritage);
        if (heritageType) obj.parent = heritageType.toString();
      }

      obj.name = s.name.escapedText.toString();

      if (s.decorators) {
        let decoratorExpression = s.decorators[0].expression as ts.CallExpression;
        // @ts-ignore
        if (decoratorExpression.expression.kind === ts.SyntaxKind.Identifier && decoratorExpression.expression.escapedText === 'Dictionary') {
          obj.kind = ClassObjectKind.dictionary;
        }
      }

      s.members.forEach(member => {
        switch(member.kind) {
          case ts.SyntaxKind.PropertySignature: {
            let prop = new PropsDeclaration();
            let m = (member as ts.PropertySignature);
            prop.name = getPropName(m.name);
            prop.readonly = isParamsReadOnly(m);

            let propKind = m.type;
            if (propKind) {
              prop.type = getParameterType(propKind);
              if (prop.type[0] === FunctionArgumentType.function) {
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
            f.args = [];
            m.parameters.forEach(params => {
              let p = paramsNodeToArguments(params);
              f.args.push(p);
            });
            obj.methods.push(f);
            if (m.type) {
              f.returnType = getParameterType(m.type);
            }
            break;
          }
          case ts.SyntaxKind.ConstructSignature: {
            let m = (member as unknown as ts.ConstructorTypeNode);
            let c = new FunctionDeclaration();
            c.name = 'constructor';
            c.args = [];
            m.parameters.forEach(params => {
              let p = paramsNodeToArguments(params);
              c.args.push(p);
            });
            obj.construct = c;
            break;
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
        functionObject.declare.returnType = getParameterType((type as ts.FunctionTypeNode).type);
        functionObject.declare.name = methodName.toString();
      }

      return functionObject;
    }
  }

  return null;
}
