export class FunctionArguments {
  name: string;
  type: string;
  required: boolean;
}

export enum PropsDeclarationKind {
  string,
  number,
  boolean,
  object,
  function
}

export class PropsDeclaration {
  kind: PropsDeclarationKind;
  name: string;
}

export class FunctionDeclaration extends PropsDeclaration {
  args: FunctionArguments[]
}

export class ClassObject {
  name: string;
  type: string;
  options: {
    flushUICommand: boolean;
  };
  props: PropsDeclaration[] = [];
  methods: FunctionDeclaration[] = [];
}
