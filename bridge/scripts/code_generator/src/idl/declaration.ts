import {ParameterType} from "./analyzer";

export enum FunctionArgumentType {
  // Basic types
  dom_string,
  object,
  int32,
  int64,
  double,
  boolean,
  function,
  void,
  any,
  null,
  undefined,
  array,
}

export class FunctionArguments {
  name: string;
  type: ParameterType[] = [];
  required: boolean;
}

export class PropsDeclaration {
  type: ParameterType[] = [];
  name: string;
  readonly: boolean;
}

export class FunctionDeclaration extends PropsDeclaration {
  args: FunctionArguments[] =  [];
  returnType: ParameterType[] = [];
}

export enum ClassObjectKind {
  interface,
  dictionary
}

export class ClassObject {
  name: string;
  parent: string;
  props: PropsDeclaration[] = [];
  methods: FunctionDeclaration[] = [];
  construct?: FunctionDeclaration;
  kind: ClassObjectKind = ClassObjectKind.interface
}

export class FunctionObject {
  declare: FunctionDeclaration
}
