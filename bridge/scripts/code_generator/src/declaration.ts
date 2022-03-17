import {ParameterType} from "./analyzer";

export enum FunctionArgumentType {
  // Basic types
  string,
  object,
  int32,
  double,
  boolean,
  function,
  any,
}

export class FunctionArguments {
  name: string;
  type: ParameterType | ParameterType[];
  required: boolean;
}

export class PropsDeclaration {
  type: ParameterType | ParameterType[];
  name: string;
  readonly: boolean;
}

export enum ReturnType {
  void,
  null
}

export class FunctionDeclaration extends PropsDeclaration {
  args: FunctionArguments[];
  returnType: ReturnType;
}

export class ClassObject {
  name: string;
  parent: string;
  props: PropsDeclaration[] = [];
  methods: FunctionDeclaration[] = [];
  construct: FunctionDeclaration;
}

export class FunctionObject {
  declare: FunctionDeclaration
}
