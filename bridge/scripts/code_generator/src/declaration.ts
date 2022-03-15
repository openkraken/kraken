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
  type: FunctionArgumentType | FunctionArgumentType[];
  required: boolean;
}

export enum PropsDeclarationKind {
  none,
  string,
  double,
  int64,
  boolean,
  object,
  function
}

export class PropsDeclaration {
  kind: PropsDeclarationKind;
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
  type: string;
  props: PropsDeclaration[] = [];
  methods: FunctionDeclaration[] = [];
}

export class FunctionObject {
  declare: FunctionDeclaration
}
