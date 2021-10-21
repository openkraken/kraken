export enum FunctionArgumentType {
  string,
  number,
  boolean,
  union
}

export class FunctionArguments {
  name: string;
  type: FunctionArgumentType;
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

export class FunctionDeclaration extends PropsDeclaration {
  args: FunctionArguments[]
}

export class ClassObject {
  name: string;
  type: string;
  props: PropsDeclaration[] = [];
  methods: FunctionDeclaration[] = [];
}
