import {ParameterType} from "./analyzer";

export enum FunctionArgumentType {
  // Basic types
  string,
  object,
  int32,
  int64,
  double,
  boolean,
  function,
  void,
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

export class FunctionDeclaration extends PropsDeclaration {
  args: FunctionArguments[];
  returnType: ParameterType | ParameterType[];
}

export class ClassObject {
  name: string;
  parent: string;
  props: PropsDeclaration[] = [];
  methods: FunctionDeclaration[] = [];
  construct?: FunctionDeclaration;
}

export class FunctionObject {
  declare: FunctionDeclaration
}
